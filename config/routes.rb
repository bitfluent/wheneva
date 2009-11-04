ActionController::Routing::Routes.draw do |map|
  map.resources :appointments
  map.root :controller => "appointments", :action => "new"
end
