class RemoveUnnecessaryTimestamps < ActiveRecord::Migration
  def self.up
    # page object
    remove_column :pages, :published_at
    remove_column :pages, :deleted_at
    remove_column :pages, :approved_at
    
    # user object
    remove_column :users, :deleted_at
    remove_column :users, :activated_at
    remove_column :users, :password_reset_at
    remove_column :users, :email_changed_at
  end

  def self.down
    # page object
    add_column :pages, :published_at, :timestamp
    add_column :pages, :deleted_at, :timestamp
    add_column :pages, :approved_at, :timestamp
    
    # user object
    add_column :users, :deleted_at, :timestamp
    add_column :users, :activated_at, :timestamp
    add_column :users, :password_reset_at, :timestamp
    add_column :users, :email_changed_at, :timestamp
  end
end
