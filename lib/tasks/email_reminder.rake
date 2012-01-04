namespace :email do
  desc 'send the weekly reminder email to all the staff who do not have any entry for task for current week'
  task :task_reminder => :environment do
    Staff.by_task_reminder(Date.today).each do |staff|
      if staff.is_active
        StaffMailer.staff_reminder_mail(staff).deliver unless (staff.external || !staff.notify)
      end
    end
  end
end