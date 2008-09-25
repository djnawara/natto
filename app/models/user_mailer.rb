class UserMailer < ActionMailer::Base
  def signup_notification(user)
    # setup all of our variables
    setup_email(user)
    @subject       += 'Please activate your new account'
    variables_hash  = {:user => user, :url => "http://#{Natto.host}/activate/#{user.activation_code}"}
    # build the email parts
    part( :content_type => "multipart/alternative" ) do |p|
      p.part(:content_type => "text/plain",
             :body => render_message("signup_notification.text.plain.haml", variables_hash))
      p.part(:content_type => "text/html",
             :body => render_message("signup_notification.text.html.haml", variables_hash))
    end
  end
  
  def forgetful_notification(user)
    setup_email(user)
    @subject       += 'Password reset request'
    variables_hash  = {:user => user, :url => "http://#{Natto.host}/reset_password/#{user.password_reset_code}"}
    # build the email parts
    part( :content_type => "multipart/alternative" ) do |p|
      p.part(:content_type => "text/plain",
             :body => render_message("forgetful_notification.text.plain.haml", variables_hash))
      p.part(:content_type => "text/html",
             :body => render_message("forgetful_notification.text.html.haml", variables_hash))
   end
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{DEFAULT_FROM}"
      @subject     = "[#{Natto.site_title}] "
      @sent_on     = Time.now
    end
end
