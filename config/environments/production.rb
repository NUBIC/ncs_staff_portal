require 'ncs_navigator/configuration'
NcsStaffPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  config.after_initialize do
    Aker.configure do
      staff_portal = Aker::Authorities::StaffPortal.new
      if File.exists?("#{Rails.root}/lib/aker/static_auth.yml") 
        psc_user_password = NcsNavigator.configuration.staff_portal['psc_user_password']
        raise "Please specify a psc user password (see README)." unless psc_user_password
        static = Aker::Authorities::Static.from_file("#{Rails.root}/lib/aker/static_auth.yml")
        static.valid_credentials!(:user, "psc_application", psc_user_password)
        authorities :cas, staff_portal, static
      else
        authorities :cas, staff_portal
      end
      central '/etc/nubic/ncs/aker-prod.yml'
    end
  end

  recipients = NcsNavigator.configuration.exception_email_recipients
  unless recipients.empty?
    config.middleware.use ExceptionNotifier,
      :email_prefix => "[NCS Navigator Ops #{NcsNavigator.configuration.study_center_short_name} #{Rails.env.titlecase}] ",
      :sender_address => NcsNavigator.configuration.staff_portal['mail_from'],
      :exception_recipients => recipients
  end
end
