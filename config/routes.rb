ActionController::Routing::Routes.draw do |map|
  # scoped urls - http://morib.wheneva.com/appointments/new
  map.with_options :conditions => { :subdomain => true } do |account|
    account.resources :appointments
    account.resources :agendas
    account.namespace :admin do |admin|
      admin.resources :appointments
    end
    account.devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
    account.connect "/admin", :controller => "admin/appointments", :action => "index"
    account.user_root '/admin/appointments', :controller => 'admin/appointments', :action => "index" # needed for devise to know where to redirect post-login
    account.settings "/admin/settings", :controller => "admin/settings", :action => "edit", :conditions => { :method => :get } 
    account.settings "/admin/settings", :controller => "admin/settings", :action => "update", :conditions => { :method => :put }
    account.connect "/accounts/check", :controller => "accounts", :action => "check"
    account.root :controller => "appointments", :action => "new"
  end

  # top-level urls - http://wheneva.com/accounts/new
  map.resources :accounts, :collection => { :check => :get }
  map.root :controller => "home", :action => "show"
end
