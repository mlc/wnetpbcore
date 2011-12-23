class LanguagesController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render :json => ISO639::FOR_SELECT.find_all { |lang| lang[0] =~ /#{params[:q]}/i }.collect { |m| { :id => m[1], :name => m[0] }}
      end
    end
  end
end