class AddActiveInactiveDateToStaff < ActiveRecord::Migration
  def self.up
    add_column(:staff, :ncs_active_date, :date)
    add_column(:staff, :ncs_inactive_date, :date)
  end

  def self.down
    remove_column(:staff, :ncs_active_date)
    remove_column(:staff, :ncs_inactive_date)
  end
end
