class AlterCommentsRenameCommentor < ActiveRecord::Migration
  def self.up
    rename_column :comments, :commentor, :name
  end

  def self.down
    rename_column :comments, :name, :commentor
  end
end
