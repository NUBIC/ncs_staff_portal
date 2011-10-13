class AddSupervisorEmployeesTable < ActiveRecord::Migration
  def self.up
    create_table "supervisor_employees" do |t|
      t.integer "supervisor_id", :null => false
      t.integer "employee_id", :null => false
    end
    execute "ALTER TABLE supervisor_employees ADD CONSTRAINT fk_supervisor_employees_supervisor FOREIGN KEY (supervisor_id) REFERENCES staff(id)"
    execute "ALTER TABLE supervisor_employees ADD CONSTRAINT fk_supervisor_employees_employee FOREIGN KEY (employee_id) REFERENCES staff(id)"
    execute "ALTER TABLE supervisor_employees ADD CONSTRAINT un_supervisor_employee UNIQUE (supervisor_id, employee_id)"
  end

  def self.down
    drop_table :supervisor_employees
  end
end
