class AppointmentMailer < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = 'meet.me'
  
  def mail(appointment)
    @recipients  = "#{appointment.email}"
    @from        = '"Support" <meet@jomcode.com>'
    @subject     = "[Meet.me] "
    @sent_on     = Time.now
    @body[:appointment] = appointment
    @body[:account] = appointment.account    
  end

end
