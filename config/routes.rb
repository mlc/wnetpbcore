ActionController::Routing::Routes.draw do |map|
  map.resources :s3_uploads

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.resources :users

  map.resource :session

  map.home '', :controller => "assets", :action => "index"
  map.lastsearch 'lastsearch', :controller => "assets", :action => "lastsearch"

  map.resources :assets, :collection => { "opensearch" => :get, "toggleannotations" => :get , "zip" => :get, "destroy_found_set" => :delete } do |assets|
    assets.resources :instantiations, :member => { "borrowings" => :get, "borrow" => :post, "return" => :post }
  end
  
  [:audience_levels, :audience_ratings, :contributor_roles, :creator_roles,
    :description_types, :format_colors, :format_generations, :format_media_types,
    :format_digitals, :format_physicals, :identifier_sources, :publisher_roles,
    :relation_types, :title_types, :essence_track_types, :essence_track_identifier_sources,
    :format_identifier_sources, :genres, :extension_names, :subjects].each do |t|
    map.resources t
  end

  map.ids 'ids', :controller => 'last_used_ids', :action => 'index'

  map.set_streamable 'options/stremable/:value', :controller => 'options', :action => 'streamable'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
