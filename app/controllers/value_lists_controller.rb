class ValueListsController < ApplicationController
  before_filter :load_list
  filter_access_to :all

  def index
    @value_lists = ValueList.all(:order => "category ASC, value ASC")
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
