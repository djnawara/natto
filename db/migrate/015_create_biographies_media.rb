class CreateBiographiesMedia < ActiveRecord::Migration
  def self.up
    create_table :biographies_media, :id => false do |t|
      t.integer       :biography_id
      t.integer       :medium_id
    end
    add_index :biographies_media, [:biography_id]
    add_index :biographies_media, [:medium_id]
  end

  def self.down
    drop_table :biographies_media
  end
end
