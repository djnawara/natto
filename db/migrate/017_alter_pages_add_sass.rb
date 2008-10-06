class AlterPagesAddSass < ActiveRecord::Migration
  def self.up
    add_column :pages, :sass, :string, :null => true, :default => ''
  end

  def self.down
    remove_column :pages, :sass
  end
end
