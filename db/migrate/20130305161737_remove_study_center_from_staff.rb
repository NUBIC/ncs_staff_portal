class RemoveStudyCenterFromStaff < ActiveRecord::Migration
  def self.up
  	remove_column :staff, :study_center
  end

  def self.down
  	add_column :staff, :study_center, :integer
  end
end
