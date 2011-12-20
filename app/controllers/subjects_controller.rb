class SubjectsController < ApplicationController
  filter_access_to :all
  before_filter :get_subject, :only => [:edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html do
        @subjects = Subject.paginate(:order => "subject ASC", :page => params[:page], :per_page => 50)
      end
      format.json do
        render :json => Subject.find(:all, 
                                     :conditions => ["subject like ? and visible = 1", "%#{params[:q]}%"],
                                     :order => "subject ASC",
                                     :limit => 100).collect { |s| { :id => s.id, :name => "#{s.subject} (#{s.subject_authority})"}}
      end
    end
  end
  
  def edit
  end
  
  def update
    if @subject.update_attributes(params[:subject])
      redirect_to subjects_url, :notice => "Successfully updated Subject"
    else
      render :action => "edit"
    end
  end
  
  def new
    @subject = Subject.new
  end
  
  def create
    @subject = Subject.new(params[:subject])
    
    if @subject.save
      redirect_to subjects_url, :notice => "Successfully created Identifier Source"
    else
      render :action => "new"
    end
  end
  
  def destroy
    if @subject.safe_to_delete?
      @subject.destroy
      redirect_to :back, :notice => "Successfully deleted Subject"
    else
      redirect_to :back, :notice => "Unable to delete Subject"
    end
  end

  protected
  def get_subject
    @subject = Subject.find(params[:id])
  end
end
