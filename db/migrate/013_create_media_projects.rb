class CreateMediaProjects < ActiveRecord::Migration
  def self.up
    create_table :media_projects, :id => false do |t|
      t.integer       :medium_id
      t.integer       :project_id
    end
    add_index :media_projects, [:medium_id]
    add_index :media_projects, [:project_id]
  end

  def self.down
    drop_table :media_projects
  end
end
