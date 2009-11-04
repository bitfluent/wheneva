class Admin::AppointmentsController < InheritedResources::Base
  before_filter :authenticate_user!
  before_filter :get_week, :only => :index

  def index
    @appointments = Appointment.weekly_appointments(@week).group_by { |t| t.confirmed_date.beginning_of_day.day}.sort
    @pendings = Appointment.pendings
  end
  
protected
  def get_week
    @week = params[:week] || Time.zone.today.cweek
  end
end
