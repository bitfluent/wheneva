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

  def requested_date_chronic
    @requested_date_chronic
  end
  
  def requested_date_chronic=(requested_date)
    @requested_date_chronic = requested_date
  end
  
  def page_title
    "#{self.name} has a meeting at #{self.appointment_date.to_s(:appointment_date)}"
  end
  
protected
  def parse_date
    return unless self.requested_date_chronic
    self.requested_date = Chronic.parse(self.requested_date_chronic)
  end
end
