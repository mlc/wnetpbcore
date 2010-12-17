class AssetsController < ApplicationController
  prepend_before_filter :fetch_asset
  filter_access_to :all
  filter_access_to :opensearch, :require => :read
  filter_access_to :toggleannotations, :require => :read
  filter_access_to :lastsearch, :require => :read
  filter_access_to :picklists, :require => :read
  filter_access_to :picklist, :require => :read
  filter_access_to :edit, :attribute_check => true
  filter_access_to :update, :attribute_check => true
  filter_access_to :destroy, :attribute_check => true

  def index
    params.delete("x")
    params.delete("y")
    alternate "application/atom+xml", params.merge(:format => "atom")
    the_query = params[:q]
    pageopts = {:page => params[:page] || 1, :per_page => 20}
    pageopts[:page] = 1 if pageopts[:page] == "" || pageopts[:page].to_i < 1
    asset_includes = [:titles, {:identifiers => [:identifier_source]}, {:instantiations => [:format, :format_ids, :annotations, :borrowings]}, :descriptions]
    the_params = params # so it can be seen inside the search DSL.
    streamable = session[:streamable] # ditto
    @search_fields = params[:search_fields]
    @show_field_chooser = !!@search_fields

    @search_object = Asset.search do
      paginate pageopts
      data_accessor_for(Asset).include = asset_includes
      if the_query
        if the_params[:search_fields]
          fulltext the_query, :fields => the_params[:search_fields].map(&:to_sym)
        else
          fulltext the_query
        end
      else
        order_by :updated_at, :desc
      end
      dynamic :facets do
        PBCore.config['facets'].map{|facet| facet[0]}.each do |facet_name|
          facet facet_name, :limit => 100
          if the_params["facet_#{facet_name}"]
            the_params["facet_#{facet_name}"].reject!{|val| val.empty?}

            the_params["facet_#{facet_name}"].each do |value|
              with facet_name, value
            end
          end
        end
      end
      if streamable
        with :online_asset, true
      end
    end
    @query = the_query
    @assets = @search_object.results

    if @assets.empty?
      flash.now[:message] = "Nothing found."
    end

    respond_to do |format|
      format.html { session[:search] = params }
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
    if @asset
      respond_to do |format|
        format.html do
          if @asset.online? && permitted_to?(:watch_video, @asset)
            enable_flash
            @video = @asset.instantiations.detect(&:online?)
          end
        end
        format.xml { render :xml => @asset.to_xml }
      end
    else
      flash[:error] = "Invalid Asset ID specified"
      redirect_to :action => 'index'
    end
  end
  
  def new
    @asset = Asset.new
    respond_to do |format|
      format.html
      format.xml do
        if PBCore.config["auto_id"]
          identifier_source = IdentifierSource.find_or_create_by_name(PBCore.config["auto_id"])
          @asset.identifiers = [Identifier.new(:identifier_source => identifier_source, :identifier => (identifier_source.next_sequence).to_s)]
        else
          @asset.identifiers.build
        end

        if PBCore.config["default_title_types"]
          PBCore.config["default_title_types"].each do |tt|
            @asset.titles << Title.new(:title_type => TitleType.find_or_create_by_name(tt))
          end
        else
          @asset.titles.build
        end
        render :xml => @asset.to_xml
      end
    end
  end
  
  def edit
    # just show form
  end
  
  def create
    Asset.transaction do
      @asset = Asset.from_xml(params[:xml])
      @success = @asset.save
      raise ActiveRecord::Rollback unless @success
    end

    if @success
      flash[:message] = "Successfully created new Asset. You must now add an instantiation for the record to be valid PBCore."
    end
  end
  
  def update
    @asset.transaction do
      parsed_asset = Asset.from_xml(params[:xml])
      [:identifiers, :titles, :subjects, :descriptions, :genres,
       :relations, :coverages, :audience_levels, :audience_ratings,
       :creators, :contributors, :publishers, :rights_summaries, :extensions].each do |field|
        @asset.send("#{field}=".to_sym, parsed_asset.send(field))
      end
      @success = @asset.save
      raise ActiveRecord::Rollback unless @success
    end
    if @success
      flash[:message] = "Successfully updated your Asset."
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

  def picklists
    classes = [Genre, Subject, ContributorRole, CreatorRole, IdentifierSource, PublisherRole, TitleType, DescriptionType, RelationType, AudienceLevel, AudienceRating, FormatIdentifierSource, EssenceTrackType, EssenceTrackIdentifierSource, FormatMediaType, FormatGeneration, FormatColor]
    @picklists = {}
    classes.each do |kl|
      if PBCore.config["big_fields"] && PBCore.config["big_fields"].include?(kl.to_s.underscore)
        @picklists[kl.to_s] = formatted_picklist_assets_path(:format => "json", :field => kl.to_s.underscore)
      else
        options = kl.quick_load_for_select(["visible = ?", true])
        @picklists[kl.to_s] = options.map(&:first)
      end
    end
    @picklists["FormatGenerations"] = @picklists["FormatGeneration"]
    @picklists.delete("FormatGeneration")
    @picklists["FormatColors"] = @picklists["FormatColor"]
    @picklists.delete("FormatColor")
    @picklists["CoverageType"] = ["Spatial", "Temporal"]
    @picklists["FormatPhysical"] = Format.quick_load_for_select(["visible = ? AND type = ?", true, "FormatPhysical"]).map(&:first)
    @picklists["FormatDigital"] = Format.quick_load_for_select(["visible = ? AND type = ?", true, "FormatDigital"]).map(&:first)
    @valuelists = ValueList.quick_load_all_for_edit_form
    respond_to do |format|
      format.json do
        response.headers["Cache-Control"] = "private, max-age=600"
        render :json => {:picklists => @picklists, :valuelists => @valuelists, :extension_names => ExtensionName.all}.to_json
      end
    end
  end

  def picklist
    if params[:term] && params[:field] && PBCore.config["big_fields"] && PBCore.config["big_fields"].include?(params[:field])
      klass = params[:field].camelize.constantize
      #FIXME: This won't work for anything but subjects, duh.
      @picklist = klass.quick_load_for_select(["subject LIKE ? ESCAPE '|'", params[:term].gsub(/[%_|]/, '|\0') + '%'], 100).map(&:first)
    else
      @picklist = []
    end

    respond_to do |format|
      format.json do
        render :json => @picklist.to_json
      end
    end
  end

  def history
    @versions = @asset.versions.all(:select => 'id, creator_id, created_at', :order => "created_at DESC")
  end

  def diff
    if params[:version_ids] && params[:version_ids].size == 2
      @versions = Version.find(params[:version_ids])
    else
      flash[:error] = "You must select exactly two versions to compare"
      redirect_to :action => 'index' and return
    end

    # ensure that @versions[0].created_at ≤ @versions[1].created_at
    if @versions[1].created_at < @versions[0].created_at
      tmp = @versions[1]
      @versions[1] = @versions[0]
      @versions[0] = tmp
    end

    @asset = @versions[0].asset

    f0 = Tempfile.new("asset-diff")
    f0 << @versions[0].body
    f0.close

    f1 = Tempfile.new("asset-diff")
    f1 << @versions[1].body
    f1.close

    @diff = `xmldiff -c #{f0.path} #{f1.path}`

    f0.unlink
    f1.unlink
  end

  protected
  def fetch_asset
    if params[:id] =~ /^[\d]+$/
      @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    elsif params[:id]
      @asset = Asset.find_by_uuid(params[:id].gsub(/^urn:uuid:/, ''), :include => Asset::ALL_INCLUDES)
    end
  end
end
