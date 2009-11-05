class Appointment < ActiveRecord::Base
  belongs_to :account
  before_save :parse_requested_date
  before_save :parse_confirmed_date
  after_save :set_conflict, :if => Proc.new {|a| !a.confirmed_date.nil? }, :unless => Proc.new {|a| a.conflicted? }
  after_save :send_mail, :unless => Proc.new {|a| a.conflicted? }
  validates_presence_of :name, :email, :phone, :brief, :on => :create, :message => "can't be blank"
  named_scope :between, lambda { |start, finish| { :conditions => ["confirmed_date >= ? AND confirmed_date <= ?", start, finish] } }
  named_scope :not_confirm, :conditions => {:confirmed_date => nil}
  named_scope :not_cancelled, :conditions => {:cancelled => false}
  named_scope :not_rejected, :conditions => {:rejected => false}
  named_scope :confirmed, :conditions => ["confirmed_date is not null"]
  named_scope :later_than_the_earliest_slot_today, lambda { {:conditions => ["confirmed_date >= ?", Time.zone.today + 9.hours]} }

  EARLIEST_SLOT = 9 # 9am
  LATEST_SLOT = 17  # 5pm

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

  def confirmed_date_chronic
    @confirmed_date_chronic
  end
  
  def confirmed_date_chronic=(date)
    @confirmed_date_chronic = date
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

  def self.open_time_slots
    ts             = TimeSlot.new
    dates          = Appointment.confirmed.later_than_the_earliest_slot_today.collect { |a| a.confirmed_date }
    slots          = ts.populate(dates)
    earliest       = Time.zone.today + 1.day + 9.hours
    earliest_slots = []

    slots.each_with_index do |slot, i|
      day = earliest + i.days
      slot.each_with_index do |s, j|
        day_hour = day + j.hours
        if day_hour <= Time.zone.now + 1.day # reject earlier empty slots
          next
        elsif s.nil?
          earliest_slots << day_hour
          break
        end
      end
    end
    earliest_slots.compact
  end

protected
  def parse_requested_date
    return unless self.requested_date_chronic
    self.requested_date ||= Chronic.parse(self.requested_date_chronic)
  end
  
  def parse_confirmed_date
    return unless self.confirmed_date_chronic
    self.confirmed_date ||= Chronic.parse(self.confirmed_date_chronic)
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
