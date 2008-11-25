class AlterProjectsSimplify < ActiveRecord::Migration
  def self.up
    remove_column :projects, :website
    remove_column :projects, :description
  end

  def self.down
    add_column :projects, :description, :text
    add_column :projects, :website, :string
  end
end
