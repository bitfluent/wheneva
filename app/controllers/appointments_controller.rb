class AppointmentsController < InheritedResources::Base
  include ApplicationHelper
  before_filter :redirect_to_admin

protected
  def begin_of_association_chain
    current_account
  end

  def redirect_to_admin
    redirect_to admin_appointments_url and return if user_signed_in?
  end
end
