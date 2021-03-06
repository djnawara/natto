require 'htmlentities'

module PagesHelper
  # Links to a page by title, or to its path.
  def link_page(page = nil, content = nil, options = {})
    return if page.nil?
    content = page.title if content.nil?
    begin
      link_to(content, 
        (page.advanced_path.blank? ? show_path(page.title.gsub(/ /, '_')) : @controller.send(page.advanced_path)),
        options.merge({:title => page.description})
      )
    rescue Exception => exception
      content
    end
  end
  
  def get_subnav(page)
    children = nil
    done = false
    while !done
      if page.nil? || (!children.nil? && children.size > 0) 
        done = true
      else
        children = page.children
        page = page.parent
      end
    end
    children
  end
end
