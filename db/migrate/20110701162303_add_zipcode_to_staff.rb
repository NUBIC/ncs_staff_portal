class AddZipcodeToStaff < ActiveRecord::Migration
  def self.up
    add_column(:staff, :zipcode, :integer)
  end

  def self.down
    remove_column(:staff, :zipcode)
  end
end
