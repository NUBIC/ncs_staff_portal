@config = YAML.load_file("/etc/nubic/ncs/staff_portal_config.yml")

ActionMailer::Base.smtp_settings = {
  :address => @config['mail']['smtp']['address'],
  :port => @config['mail']['smtp']['port'],
  :domain => @config['mail']['smtp']['domain']
}

ActionMailer::Base.default_url_options[:host] = @config['mail']['host']
ActionMailer::Base.default :from => @config['mail']['from']

Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?