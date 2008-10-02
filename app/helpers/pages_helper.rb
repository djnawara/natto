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
      coder = HTMLEntities.new
      flash.now[:error] = "<h2>Advanced Path Error</h2><p>#{coder.encode(exception.message)}</p>"
    end
  end
end
