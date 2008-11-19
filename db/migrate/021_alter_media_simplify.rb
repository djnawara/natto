class AlterMediaSimplify < ActiveRecord::Migration
  def self.up
    remove_column :media, :description
    remove_column :media, :title
    remove_column :media, :url
    remove_column :media, :medium_type
    add_column :media, :alt_text, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :media, :alt_text
    add_column :media, :description, :text
    add_column :media, :title, :string
    add_column :media, :url, :string, :null => true, :default => ''
    add_column :media, :medium_type, :string
  end
end
