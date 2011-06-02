class AddStaffRate < ActiveRecord::Migration
  def self.up
    add_column(:staff, :hourly_rate, :decimal, {:precision => 5, :scale => 2})
  end

  def self.down
    remove_column(:staff, :hourly_rate)
  end
end
