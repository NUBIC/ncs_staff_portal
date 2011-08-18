namespace :email do
  desc 'send the weekly reminder email to all the staff who do not any entry for task for current week'
  task :task_reminder => :environment do
    excluded_users = StaffPortal.configuration("users").keys unless StaffPortal.configuration("users").blank?
    Staff.by_task_reminder(Date.today).each do |staff|
      StaffMailer.staff_reminder_mail(staff).deliver unless (!excluded_users.blank? && excluded_users.include?(staff.username))
    end
  end
end