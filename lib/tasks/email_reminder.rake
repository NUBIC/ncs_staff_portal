namespace :email do
  desc 'send the weekly reminder email to all the staff who do not any entry for task for current week'
  task :task_reminder => :environment do
    Staff.by_task_reminder(Date.today).each |staff| do
      StaffMailer.staff_reminder_mail(staff).deliver
    end
  end
end