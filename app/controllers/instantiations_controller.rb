class InstantiationsController < ApplicationController
  before_filter :get_asset

  param_parsers[Mime::XML] = Proc.new do |data|
    {:xml => data}
  end
  
  def index
    @instantiations = @asset.instantiations
  end
  
  def new
    @instantiation = Instantiation.new(:asset => @asset)
    @instantiation.format_ids.build
  end
  
  def create
    if params[:xml]
      @instantiation = Instantiation.from_xml(params[:xml])
    else
      @instantiation = Instantiation.new(params[:instantiation])
    end
    @asset.instantiations << @instantiation
    respond_to do |format|
      format.html do
        if @asset.save
          flash[:message] = "Successfully created new instantiation."
          redirect_to :action => 'index'
        else
          render :action => 'new'
        end
      end
      format.xml do
        if @asset.save
          render :xml => @asset.to_xml
        else
          render :xml => "<message severity='error'>sorry, couldn't import.</message>"
        end
      end
    end
  end
  
  def edit
    @instantiation = @asset.instantiations.find(params[:id])
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
    if params[:asset_id] =~ /^\d+$/
      @asset = Asset.find(params[:asset_id], :include => [:titles, :instantiations])
    else
      @asset = Asset.find_by_uuid(params[:asset_id], :include => [:titles, :instantiations])
    end
  end
end
