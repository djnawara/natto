class CreateChangeLogs < ActiveRecord::Migration
  def self.up
    create_table :change_logs do |t|
      t.string        :object_class
      t.integer       :object_id
      t.integer       :user_id
      t.string        :action
      t.timestamp     :performed_at
      t.text          :comments
    end
  end

  def self.down
    drop_table :change_logs
  end
end
