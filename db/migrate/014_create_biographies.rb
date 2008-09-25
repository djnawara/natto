class CreateBiographies < ActiveRecord::Migration
  def self.up
    create_table :biographies do |t|
      t.string        :name
      t.string        :job_title
      t.text          :content
    end
  end

  def self.down
    drop_table :biographies
  end
end
