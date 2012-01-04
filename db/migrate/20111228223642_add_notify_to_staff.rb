class AddNotifyToStaff < ActiveRecord::Migration
  def self.up
    add_column :staff, :notify, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :staff, :notify
  end
end
