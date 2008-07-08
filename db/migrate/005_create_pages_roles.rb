class CreatePagesRoles < ActiveRecord::Migration
  def self.up
    create_table :pages_roles do |t|
      t.integer :page_id
      t.integer :role_id
    end
    add_index :pages_roles, :page_id
    add_index :pages_roles, :role_id
  end

  def self.down
    drop_table :pages_roles
  end
end
