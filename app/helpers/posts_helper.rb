module PostsHelper
  def get_recent_posts(parent, oldest_post = 1.month.ago)
    return parent.posts.find(:all, :conditions => [
              "created_at > :oldest_post",
              {:oldest_post => oldest_post.to_s(:db)}
           ], :order => 'created_at DESC')
  end
  
  def get_posts_hash(object)
    @current_year = @current_month = nil
    case(object.class.name)
    when "Page"
      posts = object.posts
    when "Post"
      @current_month = object.created_at.strftime('%B')
      @current_year = object.created_at.year.to_s
      posts = object.page.posts
    end
    hash = {}
    return hash if posts.nil? || posts.empty?
    posts.each do |post|
      year  = post.created_at.year.to_s
      month = post.created_at.strftime("%B")
      hash[year] = Hash.new unless hash[year].class.name.eql?("Hash")
      hash[year][month] = Array.new unless hash[year][month].class.name.eql?("Array")
      hash[year][month] << post
    end
    hash
  end
end