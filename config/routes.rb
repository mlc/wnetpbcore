ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.resources :users

  map.resource :session

  map.home '', :controller => "assets", :action => "index"

  map.resources :assets, :collection => { "opensearch" => :get, "toggleannotations" => :get } do |assets|
    assets.resources :instantiations
  end
  
  [:audience_levels, :audience_ratings, :contributor_roles, :creator_roles,
    :description_types, :format_colors, :format_generations, :format_media_types,
    :format_digitals, :format_physicals, :identifier_sources, :publisher_roles,
    :relation_types, :title_types, :essence_track_types, :essence_track_identifier_sources,
    :format_identifier_sources, :genres].each do |t|
    map.resources t
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
