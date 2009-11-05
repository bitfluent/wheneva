ActionController::Routing::Routes.draw do |map|
  # scoped urls - http://morib.meet.me/appointments/new
  map.with_options :conditions => { :subdomain => /./ } do |account|
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

  # top-level urls - http://meet.me/accounts/new
  map.with_options :conditions => { :subdomain => false } do |meetme|
    meetme.resources :accounts, :collection => { :check => :get }
    meetme.root :controller => "home", :action => "show"
  end
end
