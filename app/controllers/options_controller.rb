class OptionsController < ApplicationController
  def filter
    passed = params[:value].downcase
    session[:filter] = passed
    
    if session[:search].is_a?(Hash)
      session[:search].delete(:page)
      redirect_to session[:search]
    else
      redirect_to home_path
    end
  end
end
