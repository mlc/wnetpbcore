class InstantiationsController < ApplicationController
  before_filter :get_asset
  
  def index
    @instantiations = @asset.instantiations
    @page_title = "Instantiations of #{@asset.title}"
  end
  
  def new
    @instantiation = Instantiation.new(:asset => @asset)
    @instantiation.format_ids.build
    @page_title = "New instantiation of #{@asset.title}"
  end
  
  def create
    @instantiation = Instantiation.new(params[:instantiation])
    @instantiation.asset = @asset
    if @instantiation.save
      flash[:message] = "Successfully created new instantiation."
      redirect_to :action => 'index'
    else
      @page_title = "New instantiation of #{@asset.title}"
      render :action => 'new'
    end
  end
  
  def edit
    @instantiation = @asset.instantiations.find(params[:id])
    @page_title = "Edit instantiation #{@instantiation.identifier} of #{@asset.title}"
  end
  
  def update
    @instantiation = @asset.instantiations.find(params[:id])
    params[:instantiation] ||= {}
    params[:instantiation][:format_id_attributes] ||= {}
    params[:instantiation][:essence_track_attributes] ||= {}
    params[:instantiation][:annotation_attributes] ||= {}
    params[:instantiation][:date_available_attributes] ||= {}
    if @instantiation.update_attributes(params[:instantiation])
      flash[:message] = "Successfully updated your instantiation."
      redirect_to :action => 'index'
    else
      @page_title = "Edit instantiation of #{@asset.title}"
      render :action => 'edit'
    end
  end

  def destroy
    instantiation = @asset.instantiations.find(params[:id], :include => :format_ids)
    identifier = instantiation.identifier
    instantiation.destroy
    @destroyed_id = params[:id]
    
    respond_to do |format|
      format.html do
        flash[:warning] = "<strong>#{identifier}</strong> has been deleted from the database."
        redirect_to :action => 'index'
      end
      format.js
    end
  end

  protected
  def get_asset
    @asset = Asset.find(params[:asset_id], :include => [:titles, :instantiations])
  end
end
