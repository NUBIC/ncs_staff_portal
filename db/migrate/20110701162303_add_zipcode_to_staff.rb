class AddZipcodeToStaff < ActiveRecord::Migration
  def self.up
    add_column(:staff, :zip, :integer)
  end

  def self.down
    remove_column(:staff, :zip)
  end
end
