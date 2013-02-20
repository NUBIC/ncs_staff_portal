class AddYobToStaff < ActiveRecord::Migration
  def self.up
  	add_column(:staff, :yob_staff, :integer)
  end

  def self.down
  	remove_column(:staff, :yob_staff)
  end
end