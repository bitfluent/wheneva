class Admin::SettingsController < ApplicationController
  include ApplicationHelper

  def update
    begin
      current_account.update_attributes(params[:account])
    rescue
      # noop
    ensure
      redirect_to settings_url(:subdomain => current_account.subdomain)
    end
  end
end
