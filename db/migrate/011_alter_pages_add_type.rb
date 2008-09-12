class AlterPagesAddType < ActiveRecord::Migration
  def self.up
    add_column :pages, :page_type, :string, :null => false, :default => 'Normal'
  end

  def self.down
    remove_column :pages, :page_type
  end
end
