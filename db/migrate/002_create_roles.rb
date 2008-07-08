class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :title
      t.text :description
    end
  end

  def self.down
    drop_table :roles
  end
end
