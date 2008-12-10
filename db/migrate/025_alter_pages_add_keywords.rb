class AlterPagesAddKeywords < ActiveRecord::Migration
  def self.up
    add_column :pages, :keywords, :string
  end

  def self.down
    remove_column :pags, :keywords
  end
end
