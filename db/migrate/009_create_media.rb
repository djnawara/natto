class CreateMedia < ActiveRecord::Migration
  def self.up
    create_table :media do |t|
      t.string        :title
      t.text          :description
      t.integer       :parent_id
      t.string        :content_type
      t.string        :filename
      t.string        :thumbnail
      t.integer       :size
      t.integer       :width
      t.integer       :height
      t.string        :medium_type
      t.string        :state
    end
  end

  def self.down
    drop_table :media
  end
end
