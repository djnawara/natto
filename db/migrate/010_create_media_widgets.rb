class CreateMediaWidgets < ActiveRecord::Migration
  def self.up
    create_table :media_widgets, :id => false do |t|
      t.integer       :medium_id
      t.integer       :widget_id
    end
    add_index :media_widgets, [:medium_id]
    add_index :media_widgets, [:widget_id]
  end

  def self.down
    drop_table :media_widgets
  end
end
