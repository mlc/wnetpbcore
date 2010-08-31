class ValueListsController < ApplicationController
  before_filter :load_list
  filter_access_to :all

  def index
    @value_lists = ValueList.all
  end

  def new
    @value_list = ValueList.new
  end

  private
  def load_list
    if params[:id]
      @value_list = ValueList.find(params[:id])
    end
  end
end
