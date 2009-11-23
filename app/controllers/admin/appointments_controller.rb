class Admin::AppointmentsController < InheritedResources::Base
  include ApplicationHelper
  before_filter :authenticate_user!
  before_filter :get_week, :only => :index

  def index
    @pendings = end_of_association_chain.pendings
    index!
  end
  
  def update
    update! do |success, failure|
      failure.html { redirect_to admin_appointment_url(@appointment) }
    end
  end
  
protected
  def get_week
    @week = params[:week] || Time.zone.today.cweek
  end
  
  def begin_of_association_chain
    current_account
  end
  
  def collection
    @appointments ||= end_of_association_chain.weekly_appointments(@week).group_by { |t| t.confirmed_date.beginning_of_day.day}.sort
  end
  
  
end
