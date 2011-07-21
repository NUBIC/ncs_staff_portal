require 'bcdatabase'

bcconf = Bcdatabase.load[:ncs_conf,:ncs_staff_portal] # Using the bcdatabase gem for server config

ActionMailer::Base.smtp_settings = {

  :port => 25,
  :domain => "northwestern.edu"
}
ActionMailer::Base.default_url_options[:host] = bcconf["host"]
ActionMailer::Base.default :from => bcconf["from"]

Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?