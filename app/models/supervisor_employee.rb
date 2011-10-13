class SupervisorEmployee < ActiveRecord::Base
  belongs_to :supervisor, :class_name => "Staff", :foreign_key => "supervisor_id"
  belongs_to :employee, :class_name => "Staff", :foreign_key => "employee_id"
end