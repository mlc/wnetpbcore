ActionController::Routing::Routes.draw do |map|
  map.resources :s3_uploads

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.resources :users
  map.resources :ip_blocks

  map.resource :session

  map.home '', :controller => "assets", :action => "index"
  map.lastsearch 'lastsearch', :controller => "assets", :action => "lastsearch"

  map.resources :assets, :collection => { "opensearch" => :get, "toggleannotations" => :get , "zip" => :get, "destroy_found_set" => :delete, "picklists" => :get, "picklist" => :get } do |assets|
    assets.resources :instantiations, {
      :member => { "borrowings" => :get, "borrow" => :post, "return" => :post },
      :new => { "video" => :get, "upload_video" => :put, "thumbnail" => :get, "upload_thumbnail" => :put } }
  end

  map.resources :templates
  
  [:audience_levels, :audience_ratings, :contributor_roles, :creator_roles,
    :description_types, :format_colors, :format_generations, :format_media_types,
    :format_digitals, :format_physicals, :identifier_sources, :publisher_roles,
    :relation_types, :title_types, :essence_track_types, :essence_track_identifier_sources,
    :format_identifier_sources, :genres, :extension_names, :subjects].each do |t|
    map.resources t
  end

  map.resources :value_lists

  map.ids 'ids', :controller => 'last_used_ids', :action => 'index'

  map.set_streamable 'options/streamable/:value', :controller => 'options', :action => 'streamable'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
