class AlterProjectsAddPosition < ActiveRecord::Migration
  def self.up
    add_column :projects, :position, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :projects, :position
  end
end
