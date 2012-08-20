class AddHoursExpensesMilesToStaffWeeklyExpenses < ActiveRecord::Migration
  def self.up
  	add_column(:staff_weekly_expenses, :hours, :decimal, { :precision => 10, :scale => 2 })
    add_column(:staff_weekly_expenses, :miles, :decimal, { :precision => 10, :scale => 2 })
    add_column(:staff_weekly_expenses, :expenses, :decimal, { :precision => 10, :scale => 2 })
  end

  def self.down
  	remove_column(:staff_weekly_expenses, :expenses)
    remove_column(:staff_weekly_expenses, :miles)
    remove_column(:staff_weekly_expenses, :hours)
  end
end