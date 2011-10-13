class InstantiationsController < ApplicationController
  filter_access_to :all

  before_filter :get_asset
  before_filter :enable_flash, :only => :video
  skip_before_filter :verify_authenticity_token, :only => [:upload_video, :upload_thumbnail]

  param_parsers[Mime::XML] = Proc.new do |data|
    {:xml => data}
  end
  
  def index
    @instantiations = @asset.instantiations
    @templates = Instantiation.templates
  end
  
  def new
    if (params[:template_id].nil? || params[:template_id].empty?)
      @instantiation = Instantiation.new(:asset => @asset)
    else
      @instantiation = Instantiation.new_from_template(params[:template_id], @asset)
    end

    if PBCore.config["auto_id"] && PBCore.config["auto_instantiation_id"] && @asset.identifiers.any?{|inst| inst.identifier_source.name == PBCore.config["auto_id"]}
      @instantiation.format_ids = [FormatId.new({
        :format_identifier => @asset.identifiers.detect{|inst| inst.identifier_source.name == PBCore.config["auto_id"]}.identifier,
        :format_identifier_source => FormatIdentifierSource.find_or_create_by_name(PBCore.config["auto_instantiation_id"])
      })]
    else
      @instantiation.format_ids.build
    end
    @instantiation.essence_tracks.build

    respond_to do |format|
      format.html
      format.xml { render :xml => @instantiation.to_xml }
    end
  end

  def show
    @instantiation = @asset.instantiations.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @instantiation.to_xml }
    end
  end

  def upload_video
    if params[:uploaded_filename] && !(params[:uploaded_filename].empty?)
      flash[:message] = 'Your video has been uploaded and will now be processed. Please wait a few minutes for it to appear on the site.'
      Delayed::Job.enqueue Importers::VideoImportJob.new(@asset.id, params[:uploaded_filename])
    else
      flash[:warning] = 'No video was uploaded.'
    end
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.json { render :json => {:ok => true} }
    end
  end

  def upload_thumbnail
    if params[:thumbnail] && params[:thumbnail].respond_to?(:read)
      tmpfn = "/tmp/thumbnail-#{UUID.random_create}"
      File.open(tmpfn, "w") do |f|
        f << params[:thumbnail].read
      end
      Delayed::Job.enqueue Importers::ImageImportJob.new(@asset.id, tmpfn)
      respond_to do |format|
        format.html do
          flash[:message] = 'Your thumbnail has been uploaded and will now be processed. Please wait a few minutes for it to appear on the site.'
          redirect_to :action => 'index'
        end
        format.json { render :json => {:ok => true} }
      end
    else
      flash[:error] = 'You must select a thumbnail image in order to upload a thumbnail.'
      redirect_to :action => 'thumbnail'
    end
  end
  
  def create
    @instantiation = Instantiation.from_xml(params[:xml])
    uuid = @instantiation.format_ids.detect{|fid| fid.format_identifier_source == FormatIdentifierSource::OUR_UUID_SOURCE}
    unless uuid.nil?
      @instantiation.format_ids -= [uuid]
      uuid = uuid.format_identifier
      old_us = @asset.instantiations.select{|inst| inst.uuid == uuid}
      @instantiation.uuid = uuid
      @asset.instantiations -= old_us
    end
    @asset.instantiations << @instantiation
    if @asset.valid? && !old_us.nil?
      old_us.each{|ou| ou.destroy}
    end
    respond_to do |format|
      format.js do
        @success = @asset.save
        if @success
          @asset.send_later(:index!)
          flash[:message] = "Successfully created new instantiation."
        end
      end
      format.xml do
        if @asset.save
          @asset.send_later(:index!)
          render :xml => "<message severity='notice'>instantiation #{@instantiation.uuid} #{old_us.nil? ? "created" : "updated"}</message>"
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
    @instantiation.transaction do
      parsed_instantiation = Instantiation.from_xml(params[:xml])
      [:format_ids, :instantiation_dates, :essence_tracks, :annotations, :format, ## WTF DATE_AVAILABLES :date_availables
       :instantiation_media_type, :instantiation_generation, :instantiation_color, :format_location,
       :format_file_size, :format_time_start, :format_duration,
       :format_data_rate, :format_tracks, :format_channel_configuration,
       :language, :alternative_modes].each do |field|
        @instantiation.send("#{field}=".to_sym, parsed_instantiation.send(field))
      end
      @success = @instantiation.save
      if @success
        @asset.save
      else
        raise ActiveRecord::Rollback
      end
    end
    if @success
      @asset.send_later(:index!)
      flash[:message] = "Successfully updated your instantiation."
    end
  end

  def destroy
    instantiation = @asset.instantiations.find(params[:id], :include => :format_ids)
    identifier = instantiation.identifier
    instantiation.destroy
    @destroyed_online = instantiation.online?
    @destroyed_thumb = instantiation.thumbnail?
    @destroyed_id = params[:id]
    @asset.send_later(:index!)

    respond_to do |format|
      format.html do
        flash[:warning] = "<strong>#{identifier}</strong> has been deleted from the database."
        redirect_to :action => 'index'
      end
      format.js
    end
  end

  def borrowings
    @instantiation = @asset.instantiations.find(params[:id])
    @borrowings = @instantiation.borrowings.all(:order => "borrowed ASC")
  end

  def return
    @instantiation = @asset.instantiations.find(params[:id])
    @borrowing = @instantiation.current_borrowing
    unless @borrowing.nil?
      @borrowing.update_attribute(:returned, Time.now)
    end
    respond_to do |format|
      format.js
      format.html {
        flash[:message] = "The instantiation has been returned."
        redirect_to :action => :borrowings
      }
    end
  end

  def borrow
    @instantiation = @asset.instantiations.find(params[:id])
    if params[:person].nil? || params[:person].empty?
      flash[:error] = "You must specify the name of the person borrowing the item."
    else
      @instantiation.borrowings << Borrowing.new(:person => params[:person], :department => params[:department], :borrowed => Time.new)
      @instantiation.save
      flash[:message] = "The item has been marked as borrowed."
    end
    redirect_to :action => :borrowings
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
