class AccountsController < InheritedResources::Base
  layout "home"

  def create
    create! { new_user_session_url(:subdomain => @account.subdomain) }
  end

  def check
    account = end_of_association_chain.find_by_subdomain(params[:subdomain])
    render :json => { :taken => !account.nil? }
  end
end
