class AddNumericIdToStaff < ActiveRecord::Migration
  def self.up
    add_column :staff, :numeric_id, :integer
    add_index :staff, :numeric_id, :unique => true, :name => 'uq_staff_numeric_id'
    Staff.reset_column_information
    Staff.find(:all).each do |staff|
      staff.update_attribute :numeric_id, Staff.generate_random_number
    end
    change_column :staff, :numeric_id, :integer, :null => false
  end

  def self.down
    remove_column :staff, :numeric_id
  end
end
