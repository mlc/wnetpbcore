class AssetsController < ApplicationController
  def index
    @query = params[:q]
    @page_title = @query ? "Search for #{@query}" : "Assets"
    @assets = @query ? Asset.search(@query) : Asset.all

    respond_to do |format|
      format.html
#      format.xml
    end
  end
  
  def show
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
