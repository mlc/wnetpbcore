# this is the almost-abstract superclass of all the picklist controllers
class PicklistsController < ApplicationController
  before_filter :set_class_name
  
  def index
    if @klass.nil?
      @controllers = ['audience_levels', 'audience_ratings', 'contributor_roles',
        'creator_roles', 'description_types', 'format_digitals', 'format_colors',
        'format_generations', 'format_media_types', 'format_physicals',
        'identifier_sources', 'publisher_roles', 'relation_types', 'title_types',
        'essence_track_types', 'essence_track_identifier_sources',
        'format_identifier_sources'
        ].sort
      render :action => 'picklists_index'
    else
      @emit_warning = should_emit_warning
      @objects = @klass.all(:order => "name ASC")
    end
  end
  
  def update
    @obj = @klass.find(params[:id])
    @obj.update_attributes(params[@klass.to_s.underscore])
    respond_to do |format|
      format.js
      format.html { redirect_to :action => 'index' }
    end
  end
  
  def create
    @obj = @klass.new(params[@klass.to_s.underscore])
    @obj.save
    respond_to do |format|
      format.js
      format.html { redirect_to :action => 'index' }
    end
  end
  
  def destroy
    @obj = @klass.find(params[:id])
    if (@obj.safe_to_delete?)
      @destroyed_id = params[:id]
      @obj.destroy
    end
    respond_to do |format|
      format.js
      format.html { redirect_to :action => 'index' }
    end
  end
  
  protected
  def authorized?(action = action_name, resource = nil)
    logged_in? && current_user.is_admin?
  end

  def obj_type
    params[:controller] == 'picklists' ? nil : params[:controller].camelcase.singularize.constantize
  end
  
  def set_class_name
    @class_name = params[:controller].underscore.gsub('_', ' ').titlecase
    @klass = obj_type
  end

  def should_emit_warning
    true
  end
end
