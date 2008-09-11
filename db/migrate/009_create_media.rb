class CreateMedia < ActiveRecord::Migration
  def self.up
    create_table :media do |t|
      t.string        :location
      t.string        :type
      t.string        :state
    end
  end

  def self.down
    drop_table :media
  end
end
