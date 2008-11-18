ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => "assets", :action => "index"

  map.resources :assets, :collection => { "opensearch" => :get } do |assets|
    assets.resources :instantiations
  end
  
  [:identifier_sources].each do |t|
    map.resources t
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
