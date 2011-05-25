class StaffWeeklyExpense < ActiveRecord::Base
  has_many :management_tasks
  belongs_to :staff
end
