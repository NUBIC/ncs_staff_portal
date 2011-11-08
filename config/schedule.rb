job_type :rake_default, "cd :path && RAILS_ENV=:environment bundle exec rake :task :output"

every :friday, :at => '5pm' do 
  rake_default 'email:task_reminder', :output => '/var/www/apps/ncs_staff_portal/shared/log/cron.log' if Rails.env.production?
end
