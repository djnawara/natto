class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer       :post_id
      t.string        :commentor
      t.text          :content
      t.integer       :violation_votes, :default => 0
      t.string        :state
      t.timestamp     :created_at
    end
  end

  def self.down
    drop_table :comments
  end
end
