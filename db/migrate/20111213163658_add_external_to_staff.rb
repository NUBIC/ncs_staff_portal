class AddExternalToStaff < ActiveRecord::Migration
  def self.up
    add_column :staff, :external, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :staff, :external
  end
end
