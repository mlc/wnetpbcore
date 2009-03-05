class SearchController < ApplicationController
  def index
    @search = GuidedSearchContainer.from_string(params[:model])
  end

  def search
    if params[:search].respond_to?(:[])
      redirect_to :controller => 'assets', :action => 'index', :q => GuidedSearchContainer.new(params[:search]).to_s
    else
      redirect_to :action => 'index'
    end
  end
end
