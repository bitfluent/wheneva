class Account < ActiveRecord::Base
  has_many :appointments
  belongs_to :user
  belongs_to :assistant, :class_name => "User"
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :assistant
  has_attached_file :logo, :styles => { :thumb => "120x160>" }
  attr_accessor :logo_file_name

  def to_s
    self.title
  end
end
