class SearchController < ApplicationController
  FIELDS = [:identifier, :title, :subject, :description, :genre, :relation,
    :coverage, :audience_level, :audience_rating, :creator, :contributor,
    :publisher, :rights, :extension, :location, :annotation, :date]

  def index
    @fields = [:full_text] + FIELDS
  end

  def search
    query = (params.has_key?(:full_text) && !params[:full_text].empty?) ? [params[:full_text]] : []
    query += FIELDS.select{|f| params.has_key?(f) && !params[f].empty?}.map{|f| "@#{f.to_s} #{params[f]}"}
    redirect_to :controller => 'assets', :action => 'index', :q => query.join(" ")
  end

  def authorized?(action = action_name, resource = nil)
    true
  end
end
