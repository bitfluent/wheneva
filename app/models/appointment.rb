class Appointment < ActiveRecord::Base
  belongs_to :account
  before_save :parse_date
  after_save :set_conflict, :if => Proc.new {|a| !a.confirmed_date.nil? }, :unless => Proc.new {|a| a.conflicted? }
  after_save :send_mail, :unless => Proc.new {|a| a.conflicted? }
  named_scope :between, lambda { |start, finish| { :conditions => ["confirmed_date >= ? AND confirmed_date <= ?", start, finish] } }
  named_scope :not_confirm, :conditions => {:confirmed_date => nil}
  named_scope :not_cancelled, :conditions => {:cancelled => false}
  named_scope :not_rejected, :conditions => {:rejected => false}  
  
  def to_s
    name
  end
  
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
  
  def self.weekly_appointments(week)
    date = (Time.zone.today.cweek - week).week.from_now
    between(date.beginning_of_week, date.end_of_week).not_cancelled.not_rejected.all(:order => 'confirmed_date ASC')
  end
  
  def self.pendings
    not_confirm.not_cancelled.not_rejected
  end
  
protected
  def parse_date
    return unless self.requested_date_chronic
    self.requested_date = Chronic.parse(self.requested_date_chronic)
  end
  
  def set_conflict
    Appointment.all(:conditions => ["requested_date = ? AND account_id = ? ", self.confirmed_date, self.account_id]).each do |appointment|
      appointment.update_attribute('conflicted', true) if appointment.state == :unconfirmed
    end
  end
  
  def send_mail
    AppointmentMailer.deliver_mail(self)
  end
end
