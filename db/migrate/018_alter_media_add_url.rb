class AlterMediaAddUrl < ActiveRecord::Migration
  def self.up
    add_column :media, :url, :string, :null => true, :default => ''
  end

  def self.down
    remove_column :media, :url
  end
end
