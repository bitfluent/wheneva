class AccountsController < InheritedResources::Base
  layout "home"

  def create
    create! { new_user_session_url(:subdomain => @account.subdomain) }
  end
end
