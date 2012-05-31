class AddAgeGroupToStaff < ActiveRecord::Migration
  def self.up
    add_column(:staff, :age_group_code, :integer)
  end

  def self.down
    remove_column(:staff, :age_group_code)
  end
end