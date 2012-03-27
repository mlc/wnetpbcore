class AnnotationTypesController < ApplicationController
  before_filter :get_annotation_type, :only => [:edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html do
        @annotation_types = AnnotationType.paginate(:order => "name asc", :page => params[:page], :per_page => 25)
      end
      format.json do
        render :json => AnnotationType.find(:all, :conditions => ["name like ? and visible = 1", "%#{params[:term]}%"],
                                          :order => "name ASC").map(&:name)
      end
    end
  end
  
  def new
    @annotation_type = AnnotationType.new
  end

  def create
    @annotation_type = AnnotationType.new(params[:annotation_type])

    respond_to do |format|
      if @annotation_type.save
        flash[:message] = "Successfully created new annotation type."
        format.html { redirect_to annotation_types_url }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @annotation_type.update_attributes(params[:annotation_type])
        flash[:message] = "Successfully updated annotation type."
        format.html { redirect_to annotation_types_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @annotation_type.destroy
    flash[:message] = "Successfully destroyed #{@annotation_type.name}"
    respond_to do |format|
      format.html { redirect_to annotation_types_url }
    end
  end

protected
  def get_annotation_type
    @annotation_type = AnnotationType.find(params[:id])
  end
end
