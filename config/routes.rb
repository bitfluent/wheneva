ActionController::Routing::Routes.draw do |map|
  map.resources :appointments
  map.resources :accounts
  map.root :controller => "appointments", :action => "new"
end
