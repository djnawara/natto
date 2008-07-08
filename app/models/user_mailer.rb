class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{Djn2ms.host}/activate/#{user.activation_code}"
  end
  
  def forgetful_notification(user)
    setup_email(user)
    @subject    += 'Password reset request'
    @body[:url]  = "http://#{Djn2ms.host}/reset_password/#{user.password_reset_code}"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{DEFAULT_FROM}"
      @subject     = "[#{Djn2ms.site_title}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
