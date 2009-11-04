ActionController::Routing::Routes.draw do |map|
  # scoped urls - http://morib.meet.me/appointments/new
  map.with_options :conditions => { :subdomain => /./ } do |account|
    account.resources :appointments
    map.namespace :admin do |admin|
      admin.resources :appointments
    end
    account.root :controller => "appointments", :action => "new"
  end

  # top-level urls - http://meet.me/accounts/new
  map.with_options :conditions => { :subdomain => false } do |meetme|
    meetme.resources :accounts
    meetme.root :controller => "home", :action => "show"
  end
end
