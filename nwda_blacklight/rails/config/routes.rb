ActionController::Routing::Routes.draw do |map|

  # Set the default controller:
 # map.root :controller => 'home'
  
  map.from_plugin :blacklight
  
end
