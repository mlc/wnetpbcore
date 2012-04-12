# These value lists are used for providing autocomplete and picklist
# functionality for the Title section in the Asset form. As of 12/2011
# WNYC uses this for titles of type Series and Collection.
class ValueListsController < ApplicationController
  before_filter :load_list, :except => [:by_value]
  filter_access_to :all
  filter_access_to :by_value, :require => :read

  def index
    respond_to do |format|
      format.html do
        @value_lists = ValueList.all(:order => "category ASC, value ASC")
      end
      format.json do
        if value_list = ValueList.first(:conditions => ["value = ?", params[:value]])
          values = if params[:term].present?
            value_list.values.find(:all, :conditions => ["values.value LIKE ?", "%#{params[:term]}%"])
          else
            value_list.values
          end
        else
          values = []
        end
        render :json => values.map(&:value)
      end
    end
  end

  def new
    @value_list = ValueList.new
  end

  def create
    @value_list = ValueList.new(params[:value_list])
    if @value_list.save
      flash[:message] = "Value list created"
      redirect_to value_list_path(@value_list)
    else
      render :action => 'new'
    end
  end

  def show
    # render template
  end

  def update
    @value_list.bulk_values = params[:value_list][:bulk_values]
    if @value_list.save
      flash[:message] = "Value list updated"
      redirect_to value_lists_path
    else
      render :action => 'show'
    end
  end

  private
  def load_list
    if params[:id]
      @value_list = ValueList.find(params[:id])
    end
  end
end
