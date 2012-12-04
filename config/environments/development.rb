require 'aker/authorities/machine_account'

NcsStaffPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Load configuration
  config.ncs_navigator.load

  config.aker do
    static = Aker::Authorities::Static.from_file("#{Rails.root}/spec/test-users.yml")

    authorities :cas, static, Aker::Authorities::MachineAccount
    central '/etc/nubic/ncs/aker-local.yml'
  end
end

# This is necessary because there doesn't seem to be a consistent way
# to specify a CA to trust across all the various uses of Net::HTTP in
# all the libraries everywhere.
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
