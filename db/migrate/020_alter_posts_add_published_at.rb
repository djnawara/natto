class AlterPostsAddPublishedAt < ActiveRecord::Migration
  def self.up
    add_column :posts, :published_at, :timestamp
  end

  def self.down
    remove_column :posts, :published_at
  end
end
