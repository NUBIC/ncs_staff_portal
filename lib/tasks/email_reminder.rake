namespace :email do
  desc 'send the weekly reminder email to all the staff who do not have any entry for task for current week'
  task :task_reminder => :environment do
    excluded_users = NcsNavigator.configuration.staff_portal['reminder_excluded_users'].split(",") unless NcsNavigator.configuration.staff_portal['reminder_excluded_users'].blank?
    Staff.by_task_reminder(Date.today).each do |staff|
      if staff.is_active
        StaffMailer.staff_reminder_mail(staff).deliver unless (!excluded_users.blank? && excluded_users.include?(staff.username)) || staff.external
      end
    end
  end
end