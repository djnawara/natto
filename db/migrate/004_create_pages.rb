class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string      :title
      t.text        :description
      t.text        :content
      t.integer     :display_order
      t.integer     :author_id
      t.boolean     :is_home_page,        :default => 0
      t.boolean     :is_admin_home_page,  :default => 0
      t.string      :aasm_state
      t.string      :advanced_path
      t.integer     :parent_id
      t.integer     :child_count,         :default => 0
      t.datetime    :published_at
      t.datetime    :deleted_at
      t.datetime    :approved_at
    end
  end

  def self.down
    drop_table :pages
  end
end
