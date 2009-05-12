class AssetsController < ApplicationController
  filter_access_to :all
  filter_access_to :opensearch, :require => :read
  filter_access_to :toggleannotations, :require => :read
  filter_access_to :lastsearch, :require => :read
  
  def index
    alternate "application/atom+xml", :format => "atom", :q => params[:q]
    @query = params[:q]
    pageopts = {:page => params[:page] || 1, :per_page => 20}
    pageopts[:page] = 1 if pageopts[:page] == "" || pageopts[:page].to_i < 1
    asset_includes = [:titles, {:identifiers => [:identifier_source]}, {:instantiations => [:format, :format_ids, :annotations, :borrowings]}, :descriptions]
    @search_object = @query ? 
      AssetTerms.search(@query, {:match_mode => :extended, :include => {:asset => asset_includes}, :order => params[:bydate] ? "updated_at DESC" : nil}.merge(pageopts)) :
      Asset.paginate(:all, {:order => 'updated_at DESC', :include => asset_includes}.merge(pageopts))
    @assets = @query ? @search_object.map{|at| at.asset} : @search_object

    session[:search] = {:q => @query, :page => pageopts[:page].to_i == 1 ? nil : pageopts[:page]}

    respond_to do |format|
      format.html
      format.atom
    end
  end
  
  def destroy
    asset = Asset.find(params[:id], :include => :titles)
    titles = asset.title
    asset.destroy
    @destroyed_id = params[:id]
    
    respond_to do |format|
      format.html do
        flash[:warning] = "<strong>#{titles}</strong> has been deleted from the database."
        lastsearch
      end
      format.js
    end
  end
  
  def show
    alternate "application/xml", :format => "xml"
    if params[:id] =~ /^[\d]+$/
      @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    else
      @asset = Asset.find_by_uuid(params[:id].gsub(/^urn:uuid:/, ''), :include => Asset::ALL_INCLUDES)
    end
    if @asset
      respond_to do |format|
        format.html
        format.xml { render :xml => @asset.to_xml }
      end
    else
      flash[:error] = "Invalid Asset ID specified"
      redirect_to :action => 'index'
    end
  end
  
  def new
    @asset = Asset.new
    @asset.identifiers.build
    @asset.titles.build
  end
  
  def edit
    @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
  end
  
  def create
    @asset = Asset.new(params[:asset])
    if @asset.save
      flash[:message] = "Successfully created new Asset. You must now add an instantiation for the record to be valid PBCore."
      redirect_to asset_instantiations_url(@asset)
    else
      render :action => 'new'
    end
  end
  
  def update
    @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    params[:asset] ||= {}
    params[:asset][:identifier_attributes] ||= {}
    params[:asset][:title_attributes] ||= {}
    params[:asset][:subject_ids] ||= []
    params[:asset][:description_attributes] ||= {}
    params[:asset][:genre_ids] ||= []
    params[:asset][:relation_attributes] ||= {}
    params[:asset][:coverage_attributes] ||= {}
    params[:asset][:audience_rating_ids] ||= []
    params[:asset][:audience_level_ids] ||= []
    if @asset.update_attributes(params[:asset])
      flash[:message] = "Successfully updated your Asset."
      lastsearch
    else
      render :action => 'edit'
    end
  end

  # give opensearch descriptor document
  def opensearch
    respond_to do |format|
      format.xml
    end
  end

  def zip
    @query = params[:q]
    if !@query
      unless current_user.is_admin?
        flash[:error] = "Only administrators can download a zip file of the entire database."
        redirect_to :index and return
      end
      @assets = Asset.find(:all, :include => Asset::ALL_INCLUDES)
    else
      if !current_user.is_admin? && AssetTerms.search_count(@query) > 250
        flash[:error] = "Sorry, the current search is too big to be downloaded by a non-administrator."
        redirect_to :index and return
      end
      @assets = AssetTerms.search(@query, :include => {:asset => Asset::ALL_INCLUDES}).map{|at| at.asset}
    end
    # HACK HACK HACK
    zippath = File.join(Dir::tmpdir, "pbcore-#{Kernel.rand(100000)}.zip")
    Zip::ZipFile.open(zippath, Zip::ZipFile::CREATE) do |zip|
      zip.get_output_stream("README.txt") do |f|
        f.puts "This is a zipfile of PBCore data exported from the PBCore database."
        f.puts "The export was run at " + Time.new.to_s
        if @query
          f.puts "The query run was: " + @query
        else
          f.puts "All records were exported."
        end
        f.puts "#{@assets.size} results found."
        f.puts
        @assets.each do |asset|
          f.puts asset.uuid + ".xml " + asset.title
        end
      end
      @assets.each do |asset|
        zip.get_output_stream("#{asset.uuid}.xml") do |f|
          f.write asset.to_xml
        end
      end
    end

    headers['Content-Type'] = "application/zip"
    headers['Content-Disposition'] = "attachment; filename=\"pbcore-download.zip\""
    render :file => zippath
    File.unlink(zippath)
  end

  def multiprocess
    case params[:commit]
    when /^merge/i
      merge
    when /^lend/i
      multilend
    else
      lastsearch
    end
  end

  def multilend
    @instantiations = params[:instantiation_ids] ? Instantiation.find(params[:instantiation_ids], :include => [:borrowings, {:asset => [:titles]}, :format_ids, :format]) : nil
    @instantiations = @instantiations.select{|i| !i.borrowed?}

    if @instantiations.empty?
      return lastsearch
    elsif params[:person]
      if params[:person].empty?
        flash.now[:warning] = "You must specify a person to lend to."
        render :action => 'multilend' and return
      end
      @instantiations.each do |instantiation|
        instantiation.borrowings << Borrowing.new(:person => params[:person], :department => params[:department], :borrowed => Time.new)
        instantiation.save
      end
      flash[:message] = "The items have been marked as borrowed."
      return lastsearch
    else
      render :action => 'multilend'
    end
  end

  def merge
    assets = params[:asset_ids] ? Asset.find(params[:asset_ids]) : nil
    if assets.nil? || assets.size < 2
      flash[:warning] = "You must select at least two assets to merge."
    else
      first = assets.shift
      assets.each do |asset|
        first.merge(asset)
      end
      if first.save
        assets.each do |asset|
          asset.reload
          asset.destroy
        end
        flash[:message] = "Your assets have been merged."
      else
        flash[:error] = "An error occurred merging the selected assets."
      end
    end
    redirect_to :action => "index", :q => params[:q], :page => params[:page]
  end

  # if I were better at javascript, I'd do this all (including setting a cookie)
  # without talking to the server...
  def toggleannotations
    session[:show_annotations] = !session[:show_annotations]
    @visible = session[:show_annotations]
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js
    end
  end

  def lastsearch
    if session[:search].is_a?(Hash)
      redirect_to :action => 'index', :q => session[:search][:q], :page => session[:search][:page]
    else
      redirect_to :action => 'index'
    end
  end
end
