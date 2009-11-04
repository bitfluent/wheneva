class Appointment < ActiveRecord::Base
  before_save :parse_date

  def state
    if self.cancelled?
      :cancelled
    elsif self.rejected?
      :rejected
    elsif !self.confirmed_date.nil?
      if self.confirmed_date == self.requested_date
        :confirmed
      else
        :rescheduled
      end
    else
      :unconfirmed
    end
  end
  
  def appointment_date
    self.confirmed_date || self.requested_date
  end
protected
  def parse_date
    self.requested_date = Chronic.parse(self.requested_date)
  end
end
