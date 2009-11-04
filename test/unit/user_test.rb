require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:user)
  end
end
