class AssetsController < ApplicationController
  def index
    alternate "application/atom+xml", :format => "atom", :q => params[:q]
    @query = params[:q]
    @page_title = @query ? "Search for #{@query}" : "Assets"
    pageopts = {:page => params[:page] || 1, :per_page => 20}
    pageopts[:page] = 1 if pageopts[:page] == ""
    @assets = @query ? Asset.search(@query, {:match_mode => :extended}.merge(pageopts)) : Asset.paginate(:all, {:order => 'updated_at DESC'}.merge(pageopts))
    @search_object = @assets
    
    respond_to do |format|
      format.html
      format.atom
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
end
