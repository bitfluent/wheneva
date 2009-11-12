class AccountMailer < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = AppConfig.host

  def new_assistant(account)
    @recipients  = "#{account.assistant.email}"
    @from        = AppConfig.support_email
    @subject     = "[#{AppConfig.app_name}] Your account has been created"
    @sent_on     = Time.now
    @body[:account] = account
    @body[:user] = account.assistant
  end

end
