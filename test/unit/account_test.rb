require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:account)
  end
end
