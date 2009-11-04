class AppointmentsController < InheritedResources::Base
  include ApplicationHelper

protected
  def begin_of_association_chain
    current_account
  end
end
