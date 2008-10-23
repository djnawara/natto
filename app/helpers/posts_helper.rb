module PostsHelper
  def get_recent_posts(parent, oldest_post = 1.month.ago.to_s(:db))
    return parent.posts.find(:all, :conditions => [
              "created_at > :oldest_post",
              {:oldest_post => 1.month.ago.to_s(:db)}
           ], :order => 'created_at DESC')
  end
  
  def get_old_posts_hash(object, oldest_post = 1.month.ago.to_s(:db))
    @current_year = @current_month = nil
    case (object.class.name)
    when Page.name
      page = object
    when Post.name
      page = object.page
      @current_year = object.created_at.year
      @current_month = object.created_at.strftime('%B')
    when Comment.name
      page = object.post.page
    else
      return {}
    end
    # collect all posts for the parent page
    old_posts = page.posts.find(:all, :conditions => [
                  "created_at <= :youngest_post",
                  {:youngest_post => 1.month.ago.to_s(:db)}
                ], :order => 'created_at DESC')
    hash = {}
    old_posts.each do |post|
      year  = post.created_at.year.to_s
      month = post.created_at.strftime("%B")
      hash[year] = Hash.new unless hash[year].class.name.eql?("Hash")
      hash[year][month] = Array.new unless hash[year][month].class.name.eql?("Array")
      hash[year][month] << post
    end
    hash
  end
end