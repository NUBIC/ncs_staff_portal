class AddPayTypeToStaff < ActiveRecord::Migration
  def self.up
    add_column(:staff, :pay_type, :string)
    add_column(:staff, :pay_amount, :decimal, {:precision => 10, :scale => 2})
  end

  def self.down
    remove_column(:staff, :pay_amount)
    remove_column(:staff, :pay_type)
  end
end
