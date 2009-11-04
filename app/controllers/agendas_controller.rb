class AgendasController < InheritedResources::Base
  include ApplicationHelper
  before_filter :get_week, :only => :index

protected
  def begin_of_association_chain
    current_account
  end
  
  def get_week
    @week = params[:week] || Time.zone.today.cweek
  end
  
  def collection
    @agendas ||= end_of_association_chain.weekly_appointments(@week).group_by { |t| t.confirmed_date.beginning_of_day.day}.sort
  end
end
