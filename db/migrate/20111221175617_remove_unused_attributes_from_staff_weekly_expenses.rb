class RemoveUnusedAttributesFromStaffWeeklyExpenses < ActiveRecord::Migration
  def self.up
    remove_column(:staff_weekly_expenses, :expenses)
    remove_column(:staff_weekly_expenses, :miles)
    remove_column(:staff_weekly_expenses, :hours)
    remove_column(:staff_weekly_expenses, :comment)
  end

  def self.down
    add_column(:staff_weekly_expenses, :comment, :text)
    add_column(:staff_weekly_expenses, :hours, :decimal, { :precision => 5, :scale => 2 })
    add_column(:staff_weekly_expenses, :miles, :decimal, { :precision => 5, :scale => 2 })
    add_column(:staff_weekly_expenses, :expenses, :decimal, { :precision => 10, :scale => 2 })
  end
end
