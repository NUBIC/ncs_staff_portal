namespace :config do
  desc "Copy configurable images to /public/images/config folder"
  task :images => :environment do
    if NcsNavigator.configuration.footer_logo_left || NcsNavigator.configuration.footer_logo_right
      %x[ mkdir -p #{RAILS_ROOT}/public/images/config]
      %x[ cp #{NcsNavigator.configuration.footer_logo_left} #{RAILS_ROOT}/public/images/config]if NcsNavigator.configuration.footer_logo_left
      %x[ cp #{NcsNavigator.configuration.footer_logo_right} #{RAILS_ROOT}/public/images/config] if NcsNavigator.configuration.footer_logo_right
    end
  end
end