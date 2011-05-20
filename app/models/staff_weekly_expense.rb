class StaffWeeklyExpense < ActiveRecord::Base
  # validates_presence_of :week_start_date
  has_many :management_tasks
  belongs_to :staff
  # accepts_nested_attributes_for :management_tasks, :allow_destroy => true
  # belongs_to :task_type, :conditions => "list_name = 'STUDY_MNGMNT_TSK_TYPE_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :task_type_code
end
