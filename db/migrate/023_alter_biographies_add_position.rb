class AlterBiographiesAddPosition < ActiveRecord::Migration
  def self.up
    add_column :biographies, :position, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :biographies, :position
  end
end
