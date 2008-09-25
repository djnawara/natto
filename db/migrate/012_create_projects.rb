class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string        :client
      t.string        :title
      t.text          :description
      t.string        :website
      t.string        :state
    end
  end

  def self.down
    drop_table :projects
  end
end
