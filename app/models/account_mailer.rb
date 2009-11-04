class AccountMailer < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = 'meet.me'  

  def new_assistant(account)
    @recipients  = "#{account.assistant.email}"
    @from        = '"Support" <meet@jomcode.com>'
    @subject     = "[Meet.me] "
    @sent_on     = Time.now
    @body[:account] = account        
    @body[:user] = account.assistant
  end
  
end
