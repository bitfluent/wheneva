class Account < ActiveRecord::Base
  has_many :appointments
end
