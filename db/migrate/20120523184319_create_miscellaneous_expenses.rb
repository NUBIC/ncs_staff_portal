class CreateMiscellaneousExpenses < ActiveRecord::Migration
  def self.up
    create_table :miscellaneous_expenses do |t|
      t.references :staff_weekly_expense
      t.date :expense_date
      t.decimal :expenses, :precision => 10, :scale => 2
      t.decimal :miles, :precision => 5, :scale => 2
      t.string :staff_misc_exp_id, :limit => 36, :null => false
      t.text :comment
      t.timestamps
    end
    add_index :miscellaneous_expenses, :staff_misc_exp_id, :unique => true, :name => 'uq_miscellaneous_expenses_staff_misc_exp_id'
  end

  def self.down
    drop_table :miscellaneous_expenses
  end
end
