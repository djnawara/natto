class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :login
      t.string :email
      t.string :new_email
      t.string :salt
      t.string :crypted_password
      t.string :remember_token
      t.string :identity_url
      t.string :aasm_state, :default => 'passive'
      t.string :password_reset_code
      t.string :activation_code
      t.datetime :activated_at
      t.datetime :deleted_at
      t.datetime :password_reset_at
      t.datetime :email_changed_at
      t.datetime :remember_token_expires_at
    end
#    add_index :users, :login, :unique => true
#    add_index :users, :email, :unique => true
  end

  def self.down
#    remove_index :users, :login
#    remove_index :users, :email
    drop_table :users
  end
end
