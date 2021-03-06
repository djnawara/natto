require 'rexml/parsers/pullparser'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tango(basename, title = '', size = 1)
    case size
    when 1, :small
      sub_directory = '16x16/'
    when 2, :medium
      sub_directory = '22x22/'
    when 3, :large
      sub_directory = '32x32/'
    end
    img = Natto.tango_home + sub_directory + basename
    img += ".png" unless img.include?(".png")
    image_tag(img, { :class => 'icon', :title => title })
  end
  
  def new_icon(title = 'New', size = 1)
    tango('actions/document-new', title, size)
  end
  
  def show_icon(title = 'Show', size = 1)
    tango('actions/edit-find', title, size)
  end
  
  def edit_icon(title = 'Edit', size = 1)
    tango('actions/document-open', title, size)
  end
  
  def mail_icon(title = 'Mail', size = 1)
    tango('apps/internet-mail', title, size)
  end
  
  def destroy_icon(title = 'Destroy', size = 1)
    tango('places/user-trash', title, size)
  end
  
  def purge_icon(title = 'Permanently delete', size = 1)
    tango('status/user-trash-full', title, size)
  end
  
  def users_icon(title = 'Users', size = 1)
    tango('apps/system-users', title, size)
  end
  
  def roles_icon(title = 'Roles', size = 1)
    tango('apps/preferences-desktop-theme', title, size)
  end
  
  def back_icon(title = 'Back', size = 1)
    tango('actions/go-previous', title, size)
  end
  
  def dashboard_icon(title = 'Return to dashboard', size = 1)
    tango('places/start-here', title, size)
  end
  
  def logout_icon(title = 'Log out', size = 1)
    tango('actions/system-log-out', title, size)
  end
  
  def login_icon(title = 'Sign in', size = 1)
    tango('apps/preferences-system-session', title, size)
  end

  def pages_icon(title = 'Pages', size = 1)
    tango('apps/accessories-text-editor', title, size)
  end
  
  def home_icon(title = 'Home', size = 1)
    tango('actions/go-home', title, size)
  end
  
  def account_icon(title = 'Account', size = 1)
    tango('places/user-home', title, size)
  end
  
  def approve_icon(title = 'Approve', size = 1)
    tango('mimetypes/application-certificate', title, size)
  end
  
  def publish_icon(title = 'Publish', size = 1)
    tango('categories/applications-office', title, size)
  end
  
  def down_icon(title = 'Down', size = 1)
    tango('actions/go-down', title, size)
  end
  
  def up_icon(title = 'Up', size = 1)
    tango('actions/go-up', title, size)
  end
  
  def previous_icon(title = 'Previous', size = 1)
    tango('actions/go-previous', title, size)
  end
  
  def next_icon(title = 'Next', size = 1)
    tango('actions/go-next', title, size)
  end
  
  def monitor_icon(title = 'Monitor', size =1)
    tango('apps/utilities-system-monitor', title, size)
  end
  
  def refresh_icon(title = 'Refresh', size =1)
    tango('actions/view-refresh', title, size)
  end
  
  def redo_icon(title = 'Redo', size =1)
    tango('actions/edit-redo', title, size)
  end
  
  def save_icon(title = 'Save', size =1)
    tango('actions/document-save', title, size)
  end
  
  def save_as_icon(title = 'Save As', size =1)
    tango('actions/document-save-as', title, size)
  end
  
  def help_icon(title = 'Help', size = 1)
    tango('apps/help-browser', title, size)
  end
  
  def widgets_icon(title = 'Widgets', size = 1)
    tango('emblems/emblem-system', title, size)
  end
  
  def media_icon(title = 'Media', size = 1)
    tango('devices/media-optical', title, size)
  end
  
  def projects_icon(title = 'Projects', size = 1)
    tango('places/folder', title, size)
  end
  
  def biographies_icon(title = 'Biographies', size = 1)
    tango('actions/contact-new', title, size)
  end
  
  def posts_icon(title = 'Post', size = 1)
    tango('apps/internet-group-chat', title, size)
  end
  
  def sort_icon(title = 'Sort', size = 1)
    tango('apps/preferences-system-session', title, size)
  end
  
  def contact_categories_icon(title = 'Contact categories', size = 1)
    tango('mimetypes/x-office-address-book', title, size)
  end
  
  def format_date(date = Time.now, style = :short, time = false, zone = true)
    date = Time.parse(date) if date.class.name.eql?("String")
    case style
    when :natural
      output  = date.strftime('%B ')
      output += date.strftime('%d').to_i.ordinalize
      output += date.strftime(', %Y') unless Time.now.strftime('%Y').eql?(date.strftime('%Y'))
      output += ' ' + format_time(date, :twelve, zone) if time
      return output
    when :short
      output  = date.strftime('%b %d')
      output += date.strftime(', %Y') unless Time.now.strftime('%Y').eql?(date.strftime('%Y'))
      output += ' ' + format_time(date, :twenty_four, zone) if time
      return output
    when :long
      output = date.strftime('%A, %B ') + date.strftime('%d').to_i.ordinalize + date.strftime(', %Y')
      output += ' at ' + format_time(date, :twelve, zone) if time
      output
    end
  end
  
  def format_time(date = Time.now, style = :twelve, zone = true)
    case style
    when :twelve
      output  = date.strftime('%I:%M %p')
      output += date.strftime(' %Z') if zone
      output
    when :twenty_four
      output  = date.strftime('%H:%M')
      output += date.strftime(' %Z') if zone
      output
    end
  end
  
  def ie?
    m = /MSIE\s+([0-9, \.]+)/.match(request.user_agent)
    unless m.nil?
      m[1].to_f
    end
  end
  
  def submit_label(object = nil, create = "Create", edit = "Edit")
    return "Submit" if object.nil?
    object.new_record? ? create : edit
  end
  
  # finds the current item in a collection, as well as indexes for the next and previous items.
  def get_indices(collection = nil, index = nil)
    return nil if collection.nil? || collection.blank?
    index = 0 if index.nil?
    index = index.to_i if index.class.name.eql?("String")
    if index == 0
      current_medium  = collection.first
      previous_medium = (collection.size > 0 ? collection.size - 1 : 0)
      next_medium     = (collection.size > 1 ? 1 : 0)
    else
      current_medium  = collection[index]
      previous_medium = (index == 0 ? (collection.size - 1) : index - 1)
      next_medium     = (index >= (collection.size - 1) ? 0 : index + 1)
    end
    return current_medium, previous_medium, next_medium
  end

  def truncate_words(text, word_count = 50, end_string = ' …')
    words = text.split()
    words[0..(word_count - 1)].join(' ') + (words.length > word_count ? end_string : '')
  end

  def truncate_html(input, max_word_count = 50, extension = "&hellip;")
    def attrs_to_s(attrs)
      return '' if attrs.empty?
      attrs.to_a.map { |attr| %{#{attr[0]}="#{attr[1]}"} }.join(' ')
    end
    
    p = REXML::Parsers::PullParser.new(input)
    tags = []
    word_count = 0
    results = ''
    while p.has_next? && word_count < max_word_count
      p_e = p.pull
      case p_e.event_type
      when :start_element
        tags.push p_e[0]
        results << "<#{tags.last} #{attrs_to_s(p_e[1])}>"
      when :end_element
        results << "</#{tags.pop}>"
      when :text
        logger.debug("P_E: #{p_e[0]}")
        results << p_e[0]
        word_count += p_e[0].split.size
        results << extension if word_count > max_word_count
      else
        results << "<!-- #{p_e.inspect} -->"
      end
    end
    tags.reverse.each do |tag|
      results << "</#{tag}>"
    end
    results.to_s
  end
end
