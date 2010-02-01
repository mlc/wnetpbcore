class OptionsController < ApplicationController
  def streamable
    passed = params[:value].downcase
    session[:streamable] = (passed == "on" || passed == "true" || passed == "1")
    if session[:search].is_a?(Hash)
      session[:search].delete(:page)
      redirect_to session[:search]
    else
      redirect_to home_path
    end
  end
end
