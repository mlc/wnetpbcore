class AssetsController < ApplicationController
  def index
    alternate "application/atom+xml", :format => "atom", :q => params[:q]
    @query = params[:q]
    @page_title = @query ? "Search for #{@query}" : "Assets"
    pageopts = {:page => params[:page] || 1, :per_page => 20}
    pageopts[:page] = 1 if pageopts[:page] == ""
    @search_object = @query ? 
      AssetTerms.search(@query, {:match_mode => :extended, :include => {:asset => :titles}}.merge(pageopts)) :
      Asset.paginate(:all, {:order => 'updated_at DESC', :include => :titles}.merge(pageopts))
    @assets = @query ? @search_object.map{|at| at.asset} : @search_object
    
    respond_to do |format|
      format.html
      format.atom
    end
  end
  
  def destroy
    asset = Asset.find(params[:id], :include => :titles)
    titles = asset.titles.map{|t| t.title}.join("; ")
    asset.destroy
    @destroyed_id = params[:id]
    
    respond_to do |format|
      format.html do
        flash[:warning] = "<strong>#{titles}</strong> has been deleted from the database."
        redirect_to :action => 'index'
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
      @page_title = "View Asset"
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
    @page_title = "New Asset"
  end
  
  def edit
    @asset = Asset.find(params[:id])
    @page_title = "Edit Asset"
  end

  # give opensearch descriptor document
  def opensearch
    respond_to do |format|
      format.xml
    end
  end
end
