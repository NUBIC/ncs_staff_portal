require File.expand_path("../../lib/ncs_navigator_configuration_helper", __FILE__)
job_type :rake_default, "cd :path && RAILS_ENV=:environment bundle exec rake :task :output"

if NcsNavigatorConfigurationHelper.email_reminder
  every :friday, :at => '5pm' do 
    rake_default 'email:task_reminder', :output => '/var/www/apps/ncs_staff_portal/shared/log/cron.log'
  end
end
