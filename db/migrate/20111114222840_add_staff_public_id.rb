require 'mdes_record'

class AddStaffPublicId < ActiveRecord::Migration
  def self.up
    add_column :staff, :staff_id, :string, :limit => 36
    add_index :staff, :staff_id, :unique => true, :name => 'uq_staff_staff_id'
    Staff.reset_column_information
    Staff.find(:all).each do |staff|
      staff.update_attribute :staff_id, MdesRecord::ActsAsMdesRecord.create_public_id_string
    end
    change_column :staff, :staff_id, :string, :limit => 36, :null => false
  end

  def self.down
    remove_column :staff, :staff_id
  end
end
