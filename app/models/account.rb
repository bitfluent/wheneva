class Account < ActiveRecord::Base
  has_many :appointments
  belongs_to :user
  accepts_nested_attributes_for :user

  def to_s
    self.title
  end
end
