class CreateStaffWeeklyExpenses < ActiveRecord::Migration
  def self.up
    create_table :staff_weekly_expenses do |t|
      t.references :staff
      t.date :week_start_date
      t.decimal :staff_pay
      t.decimal :staff_hours
      t.decimal :staff_expenses
      t.decimal :staff_miles
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :staff_weekly_expenses
  end
end
