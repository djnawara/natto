class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer       :page_id
      t.string        :title
      t.text          :description
      t.text          :content
      t.string        :state
      t.timestamp     :created_at
    end
  end

  def self.down
    drop_table :posts
  end
end
