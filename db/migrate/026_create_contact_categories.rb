class CreateContactCategories < ActiveRecord::Migration
  def self.up
    create_table :contact_categories do |t|
      t.integer       :position
      t.string        :title
      t.text          :name
      t.text          :email
    end
  end

  def self.down
    drop_table :contact_categories
  end
end
