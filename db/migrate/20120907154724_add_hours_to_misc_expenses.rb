class AddHoursToMiscExpenses < ActiveRecord::Migration
  def self.up
  	add_column(:miscellaneous_expenses, :hours, :decimal, { :precision => 10, :scale => 2 })
  end

  def self.down
    remove_column(:miscellaneous_expenses, :hours)
  end
end
