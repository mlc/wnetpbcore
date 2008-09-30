ActionController::Routing::Routes.draw do |map|
  map.home '/', :controller => :assets, :action => :index
#  map.resources :assets
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
