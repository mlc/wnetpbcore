class AssetsController < ApplicationController
  filter_access_to :all
  filter_access_to :opensearch, :require => :read
  filter_access_to :toggleannotations, :require => :read
  filter_access_to :lastsearch, :require => :read
  
  def index
    params.delete("x")
    params.delete("y")
    alternate "application/atom+xml", params.merge(:format => "atom")
    the_query = params[:q]
    pageopts = {:page => params[:page] || 1, :per_page => 20}
    pageopts[:page] = 1 if pageopts[:page] == "" || pageopts[:page].to_i < 1
    asset_includes = [:titles, {:identifiers => [:identifier_source]}, {:instantiations => [:format, :format_ids, :annotations, :borrowings]}, :descriptions]
    the_params = params # so it can be seen inside the search DSL.

    @search_object = Asset.search do
      paginate pageopts
      data_accessor_for(Asset).include = asset_includes
      if the_query
        fulltext the_query
      else
        order_by :updated_at, :desc
      end
      Asset::FACET_NAMES.each do |facet_name|
        facet facet_name, :limit => 15
        if the_params["facet_#{facet_name}"]
          the_params["facet_#{facet_name}"].each do |value|
            with facet_name, value
          end
        end
      end
    end
    @query = the_query
    @assets = @search_object.results

    session[:search] = params
    
    if @assets.empty?
      flash.now[:message] = "Nothing found."
    end

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

  # DANGEROUS!
  def destroy_found_set
    if params[:q].nil? || params[:q].strip.blank?
      flash[:error] = "No search query provided."
      redirect_to :action => "index" and return
    end

    query = params[:q]
    asset_terms = AssetTerms.search(query, {:match_mode => :extended, :per_page => 10000, :include => { :asset => Asset::ALL_INCLUDES }})
    asset_terms.each do |at|
      at.asset.destroy
    end

    flash[:message] = "#{asset_terms.size} assets matching the query <tt>#{params[:q]}</tt> destroyed."
    session[:search] = nil
    redirect_to :action => "index"
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
      redirect_to session[:search]
    else
      redirect_to :action => 'index'
    end
  end
end
