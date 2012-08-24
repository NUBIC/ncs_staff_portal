class UpdateWeeklyExpensesRateDecimalField < ActiveRecord::Migration
  def self.up
  	change_column(:staff_weekly_expenses, :rate, :decimal, { :precision => 10, :scale => 2 })
  end

  def self.down
    change_column(:staff_weekly_expenses, :rate, :decimal, { :precision => 5, :scale => 2 })
  end
end
