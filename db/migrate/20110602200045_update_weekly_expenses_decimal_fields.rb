class UpdateWeeklyExpensesDecimalFields < ActiveRecord::Migration
  # Remap list
  # :old_name => :new_name
  REMAP = {
  :staff_pay => :rate,
  :staff_expenses => :expenses,
  :staff_miles => :miles,
  :staff_hours => :hours
  }

  def self.up
    REMAP.each do |old_name,new_name|
      rename_column(:staff_weekly_expenses, old_name, new_name)
      change_column(:staff_weekly_expenses, new_name, :decimal, {
        :precision => (new_name == :expenses)? 10 : 5,
        :scale => 2
        })
    end
  end

  def self.down
    REMAP.each do |old_name,new_name|
      rename_column(:staff_weekly_expenses, new_name, old_name)
      change_column(:staff_weekly_expenses, old_name, :decimal)
    end
  end
end
