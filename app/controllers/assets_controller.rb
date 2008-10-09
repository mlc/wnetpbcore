class AssetsController < ApplicationController
  def index
    @page_title = "Assets"
    @assets = Asset.all
  end
  
  def show
    @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    @page_title = "View Asset"
    respond_to do |format|
      format.html
      format.xml { render :xml => @asset.to_xml }
    end
  end
end
