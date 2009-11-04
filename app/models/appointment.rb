class Appointment < ActiveRecord::Base
  before_save :parse_date

protected
  def parse_date
    self.requested_date = Chronic.parse(self.requested_date)
  end
end
