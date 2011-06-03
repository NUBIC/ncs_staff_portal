class StaffWeeklyExpense < ActiveRecord::Base
  validates_presence_of :week_start_date
  has_many :management_tasks
  belongs_to :staff
end
