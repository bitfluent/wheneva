class AccountsController < InheritedResources::Base
  def create
    create! { new_user_session_url(:subdomain => @account.subdomain) }
  end
end
