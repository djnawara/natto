module PostsHelper
  def get_recent_posts(parent, oldest_post = 6.months.ago, state = :published)
    return parent.posts.find_in_state(:all, state, :conditions => ["published_at > :oldest_post", {:oldest_post => oldest_post.to_s(:db)}], :order => 'published_at DESC')
  end
  
  def get_posts_hash(object, oldest_post = 6.months.ago, state = :published)
    @current_year = @current_month = nil
    case(object.class.name)
    when "Page"
      posts = object.posts.find_in_state(:all, state, :conditions => ["published_at <= :oldest_post", {:oldest_post => oldest_post.to_s(:db)}], :order => 'published_at DESC')
    when "Post"
      return nil if @object.page.nil?
      @current_month = object.created_at.strftime('%B')
      @current_year = object.created_at.year.to_s
      posts = object.page.posts.find_in_state(:all, :published, :conditions => ["published_at <= :oldest_post", {:oldest_post => oldest_post.to_s(:db)}], :order => 'published_at DESC')
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