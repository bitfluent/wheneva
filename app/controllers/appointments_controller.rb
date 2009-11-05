class AppointmentsController < InheritedResources::Base
  include ApplicationHelper
  before_filter :redirect_to_admin

  def index
    redirect_to root_url
  end

  def create
    @appointment = current_account.appointments.build(params[:appointment])
    @appointment.token = UUIDTools::UUID.random_create.to_s
    create! do |success, failure|
      success.html { redirect_to appointment_url(@appointment, :token => @appointment.token) }
      failure.html { render :action => "new" }
    end
  end
protected
  def begin_of_association_chain
    current_account
  end

  def resource
    r = end_of_association_chain.find_by_id_and_token(params[:id], params[:token])
    raise ActiveRecord::RecordNotFound unless r
    r
  end

  def redirect_to_admin
    redirect_to admin_appointments_url and return if user_signed_in?
  end
end
