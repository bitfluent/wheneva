class User < ActiveRecord::Base
  devise :recoverable, :rememberable
end
