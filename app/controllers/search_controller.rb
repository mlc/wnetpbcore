class SearchController < ApplicationController
  FIELDS = [:identifier, :title, :subject, :description, :genre, :relation,
    :coverage, :audience_level, :audience_rating, :creator, :contributor,
    :publisher, :rights, :extension, :location, :annotation, :date]

  def index
    @fields = [:full_text] + FIELDS
  end

  def search
    query = params[:full_text]
    FIELDS.each do |field|
      query += " @#{field.to_s} #{params[field]}" unless params[field].empty?
    end
    redirect_to :controller => 'assets', :action => 'index', :q => query
  end

  def authorized?(action = action_name, resource = nil)
    true
  end
end
