class AddForeignKeyToManagementTasks < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM management_tasks WHERE staff_weekly_expense_id NOT IN (SELECT id FROM staff_weekly_expenses)"
    execute "ALTER TABLE management_tasks ADD CONSTRAINT fk_management_tasks_weekly_expense FOREIGN KEY (staff_weekly_expense_id) REFERENCES staff_weekly_expenses(id)"
  end

  def self.down
    execute "ALTER TABLE management_tasks DROP CONSTRAINT fk_management_tasks_weekly_expense"
  end
end
