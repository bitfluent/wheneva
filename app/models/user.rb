class User < ActiveRecord::Base
  validates_presence_of :email, :password, :on => :create, :message => "can't be blank"
  devise :recoverable, :rememberable
end
