ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => "assets", :action => "index"

  map.resources :assets, :collection => { "opensearch" => :get } do |assets|
    assets.resources :instantiations
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
