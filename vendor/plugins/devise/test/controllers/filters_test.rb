require 'test/test_helper'
require 'ostruct'

class MockController < ApplicationController
  attr_accessor :env

  def request
    self
  end

  def path
    ''
  end
end

class ControllerAuthenticableTest < ActionController::TestCase

  def setup
    @controller = MockController.new
    @mock_warden = OpenStruct.new
    @controller.env = { 'warden' => @mock_warden }
  end

  test 'setup warden' do
    assert_not_nil @controller.warden
  end

  test 'provide access to warden instance' do
    assert_equal @controller.warden, @controller.env['warden']
  end

  test 'run authenticate? with scope on warden' do
    @mock_warden.expects(:authenticated?).with(:my_scope)
    @controller.signed_in?(:my_scope)
  end

  test 'proxy signed_in? to authenticated' do
    @mock_warden.expects(:authenticated?).with(:my_scope)
    @controller.signed_in?(:my_scope)
  end

  test 'run user with scope on warden' do
    @mock_warden.expects(:user).with(:admin).returns(true)
    @controller.current_admin

    @mock_warden.expects(:user).with(:user).returns(true)
    @controller.current_user
  end

  test 'proxy logout to warden' do
    @mock_warden.expects(:user).with(:user).returns(true)
    @mock_warden.expects(:logout).with(:user).returns(true)
    @controller.sign_out(:user)
  end

  test 'proxy user_authenticate! to authenticate with user scope' do
    @mock_warden.expects(:authenticate!).with(:scope => :user)
    @controller.authenticate_user!
  end

  test 'proxy admin_authenticate! to authenticate with admin scope' do
    @mock_warden.expects(:authenticate!).with(:scope => :admin)
    @controller.authenticate_admin!
  end

  test 'proxy user_authenticated? to authenticate with user scope' do
    @mock_warden.expects(:authenticated?).with(:user)
    @controller.user_signed_in?
  end

  test 'proxy admin_authenticated? to authenticate with admin scope' do
    @mock_warden.expects(:authenticated?).with(:admin)
    @controller.admin_signed_in?
  end

  test 'proxy user_session to session scope in warden' do
    @mock_warden.expects(:session).with(:user).returns({})
    @controller.user_session
  end

  test 'proxy admin_session to session scope in warden' do
    @mock_warden.expects(:session).with(:admin).returns({})
    @controller.admin_session
  end

  test 'sign in automatically proxy to set user on warden' do
    @mock_warden.expects(:set_user).with(user = mock, :scope => :user).returns(true)
    @controller.sign_in(:user, user)
  end
end
