class TemplatesController < ApplicationController
  filter_access_to :all
  before_filter :get_instantiation

  def index
    @templates = Instantiation.templates
  end

  def edit
    # show form
  end

  def update
    @instantiation.update_attribute(:template_name, params[:instantiation][:template_name])
    flash[:message] = "Template name set."
    redirect_to :action => 'index'
  end

  def destroy
    @instantiation.update_attribute(:template_name, nil)
  end

  protected
  def get_instantiation
    if params[:id] =~ /^\d+$/
      @instantiation = Instantiation.find(params[:id])
    end
  end
end
