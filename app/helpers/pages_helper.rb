require 'htmlentities'

module PagesHelper
  # Links to a page by title, or to its path.
  def link_page(page = nil, content = nil, options = {})
    return if page.nil?
    content = page.title.capitalize if content.nil?
    begin
      link_to(content, 
        (page.advanced_path.blank? ? show_path(page.title.gsub(/ /, '_')) : @controller.send(page.advanced_path)),
        options.merge({:title => page.description})
      )
    rescue Exception => err
      coder = HTMLEntities.new
      flash.now[:error] = "<h2>Advanced Path Error</h2><p>#{coder.encode(exception.message)}</p>"
    end
  end
  
  # Creates nested unordered lists for the page navigation.
  def create_navigation(pages = nil)
    # handle empty collections of child nodes
    return '' if pages == []
    # default action is to grab the root nodes
    pages = Page.find_in_state(:all, :published, :conditions => {:parent_id => nil}, :order => "is_home_page DESC, is_admin_home_page, display_order ASC") if pages.nil?
    
    output = '<ul>'
    pages.each do |page|
      if User.authorized_for_page?(current_user, page)
        ######
        # first, let's figure out what class our list-item should have
        css_class  = ''
        
        # determine if this is the current page
        css_class  = 'active' if @page && (page == @page || @page.root == page)
        
        # determine if this is the home page
        css_class += (css_class.blank? ? '' : ' ') + 'home' if page.is_home_page?
        
        ######
        # build the opening list-item tag, with the appropriate classes
        output += '<li title="' + page.description + '"'
        output +=   ' class="' + css_class + '"' unless css_class.blank?
        output += '>'
        
        ######
        # let's add the actual link, but...
        # first wrap it in a div, since we may have a nested list
        output +=   '<div>'
        output +=     @page == page ? page.title : link_page(page)
        output +=   '</div>'
        
        ########
        # Time to draw child links
        output += create_navigation(Page.find_in_state(:all, :published, :conditions => {:parent_id => page.id}, :order => 'display_order')) unless page.child_count == 0
        
        ########
        # close out the list-item
        output += '</li>'
      end
    end
    output += '</ul>'
    # finished recursively building our navigation string
    return output
  end
  
  # Draws pages for the page administration (index).
  def draw_page_rows(pages = nil)
    output = ''
    for page in pages
      output += '<div class="tree_node '
        output += cycle('even', 'odd')
        output += " #{page.current_state.to_s}"
        output += " #{page.title.downcase.underscore}"
        output += ' home_page' if page.is_home_page?
        output += ' admin_home_page' if page.is_admin_home_page?
      output += '">'
        output += '<div class="float_right">'
          unless page.is_home_page? || page.is_admin_home_page?
            output += link_to(down_icon, {:action => 'set_display_order', :id => page, :display_order => page.display_order+1}, :method => :put) unless page.is_max_display_order? || page.current_state == :deleted
            output += link_to(up_icon, {:action => 'set_display_order', :id => page, :display_order => page.display_order-1}, :method => :put) unless page.is_min_display_order? || page.current_state == :deleted
            output += link_to(previous_icon, {:action => 'set_parent', :id => page, :parent_id => page.parent.parent_id}, :method => :put) unless page.parent_id.nil? || page.current_state == :deleted
            output += link_to(next_icon, {:action => 'set_parent', :id => page, :parent_id => page.get_sibling_id}, :method => :put) unless page.siblings.size == 0 || (page.is_min_display_order? && !page.parent_id.nil?) || page.current_state == :deleted
          end
          
          output += link_to(monitor_icon('Statistics'), instance_logs_path('page', page))
          output += link_to(new_icon('New child'), new_page_path(:parent_id => page.id))
          output += link_to(edit_icon('Edit'), edit_page_path(page))
          output += link_to(roles_icon('Manage roles'), roles_page_path(page))
          output += link_to(destroy_icon('Destroy'), page, :method => :delete) unless page.current_state == :deleted || page.is_important?
          output += link_to(purge_icon('Permanently delete!'), {:action => 'purge', :id => page}, :method => :delete) if page.current_state == :deleted
          output += link_to(refresh_icon('Undelete page'), {:action => 'undelete', :id => page}) if page.current_state == :deleted
          output += link_to(tango('actions/process-stop', 'Unpublish page'), {:action => 'unpublish', :id => page}, :confirm => "Are you sure you want to unpublish " + page.title + "?", :method => :put) if page.current_state == :published && !page.is_important?
          output += link_to(publish_icon('Publish page'), {:action => 'publish', :id => page}, :method => :put) if (page.current_state == :approved || page.current_state == :unpublished)
          output += link_to(approve_icon('Approve page'), {:action => 'approve', :id => page}) if page.current_state == :pending_review
        output += '</div>'
        
        output += '<h2>'
          output += link_page(page)
          output += (page.is_home_page? ? home_icon : '')
          output += (page.is_admin_home_page? ? account_icon('Admin home') : '')
        output += '</h2>'
        
        # recurse
        output += draw_page_rows(page.children) if page.child_count > 0
      output += '</div>'
    end
    output
  end
  
  def draw_sitemap_rows(pages = nil)
    output = ''
    for page in pages
      output += '<div class="sitemap_node ' + cycle('even', 'odd') + '">'
      output += link_page(page)
      output += draw_sitemap_rows(page.children)
      output += '</div>'
    end
    output
  end
end
