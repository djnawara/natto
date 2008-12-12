class Mailer < ActionMailer::Base
  def contact(contact)
    setup_email(contact)
    # set up the rest of the email parts
    part( :content_type => "multipart/alternative" ) do |p|
      p.part(:content_type => "text/plain",
             :body => render_message("contact.text.plain.haml", {:contact => contact}))
      p.part(:content_type => "text/html",
             :body => render_message("contact.text.html.haml", {:contact => contact}))
    end
  end

protected
  
  def setup_email(contact)
    category = ContactCategory.find_by_id(contact.message_type)
    @recipients     = category.email
    @from           = contact.named_email
    @subject        = "#{Natto.site_title} contact email"
    @sent_on        = Time.now
    @body[:contact] = contact
  end
end
