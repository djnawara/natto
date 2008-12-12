class ContactsController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :contact, :send_contact]
  skip_before_filter :admin_required, :only => [:index, :contact, :send_contact]

  def index
    @object = Contact.new
    render :action => "contact"
  end

  def contact
    @object = Contact.new
  end

  def send_contact
    @contact = Contact.new(params[:contact])
    contact_page = Page.find_by_is_contact_page(true)
    if @contact.save
      # Send the email
      if Mailer::deliver_contact(@contact)
        begin
          flash[:notice] = 'Thank you for the email; we will get back to you as soon as possible!'
        rescue
          flash[:error] = 'Sorry, but we had trouble delivering your mail.  Please try again.'
        ensure
          redirect_to :controller => 'pages', :action => 'show', :title => contact_page.title.gsub(/ /, "_")
        end
      end
    else
      @page = contact_page
      render :template => 'pages/contact'
    end
  end
end
