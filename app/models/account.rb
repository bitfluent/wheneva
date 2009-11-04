class Account < ActiveRecord::Base
  has_many :appointments
  has_many :agendas, :class_name => "Appointment"
  belongs_to :user
  belongs_to :assistant, :class_name => "User"
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :assistant
  has_attached_file :logo, :styles => { :thumb => "120x160>" }

  def to_s
    self.title
  end
end
