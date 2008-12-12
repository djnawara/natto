class AlterPagesAddIsContactPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :is_contact_page, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :pages, :is_contact_page
  end
end
