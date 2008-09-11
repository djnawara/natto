class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.string        :title
      t.text          :description
      t.text          :content
      t.string        :type
      t.string        :state
    end
  end

  def self.down
    drop_table :widgets
  end
end
