class CreateMediaPosts < ActiveRecord::Migration
  def self.up
    create_table :media_posts, :id => false do |t|
      t.integer       :medium_id
      t.integer       :post_id
    end
    add_index :media_posts, [:medium_id]
    add_index :media_posts, [:post_id]
  end

  def self.down
    drop_table :media_posts
  end
end
