module PostsHelper
  def get_recent_posts(parent, oldest_post = 1.month.ago.to_s(:db))
    return parent.posts.find(:all, :conditions => [
              "created_at > :oldest_post",
              {:oldest_post => 1.month.ago.to_s(:db)}
           ], :order => 'created_at DESC')
  end
  
  def get_old_posts_hash(parent, oldest_post = 1.month.ago.to_s(:db))
    old_posts = parent.posts.find(:all, :conditions => [
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