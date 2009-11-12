class AppointmentMailer < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = AppConfig.host
  
  def mail(appointment)
    @recipients  = "#{appointment.email}"
    @from        = AppConfig.support_email
    @subject     = "[#{AppConfig.app_name}] #{appointment.name} has requested an appointment"
    @sent_on     = Time.now
    @body[:appointment] = appointment
    @body[:account] = appointment.account
  end

end
