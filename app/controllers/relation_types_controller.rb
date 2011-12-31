class RelationTypesController < ApplicationController
  filter_access_to :all
  before_filter :get_relation_type, :only => [:edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html { @relation_types = RelationType.paginate(:order => "name asc", :page => params[:page], :per_page => 25) }
      format.json { render :json => RelationType.find(:all, :conditions => ["name like ? and visible = 1", "%#{params[:term]}%"],
                                        :order => "name ASC").map(&:name) }
    end
    
  end
  
  def new
    @relation_type = RelationType.new
  end
  
  def create
    @relation_type = RelationType.new(params[:relation_type])
    
    respond_to do |format|
      if @relation_type.save
        flash[:message] = "Successfully created new relation type."
        format.html { redirect_to relation_types_url }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @relation_type.update_attributes(params[:relation_type])
        flash[:message] = "Successfully updated relation type."
        format.html { redirect_to relation_types_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @relation_type.destroy
    flash[:message] = "Successfully destroyed #{@relation_type.name}"
    respond_to do |format|
      format.html { redirect_to relation_types_url }
    end
  end
  
  def set_standard_pbcore
    @standard_pbcore =
      [
       "Has Format", "Is Format Of", "Has Part", "Is Part Of", "Has Version",
       "Is Version Of", "References", "Is Referenced By", "Replaces",
       "Is Replaced By", "Requires", "Is Required By", "Other"
      ].to_set.freeze
  end
  
protected
  def get_relation_type
    @relation_type = RelationType.find(params[:id])
  end
end
