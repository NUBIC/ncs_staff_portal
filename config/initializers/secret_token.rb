# -*- coding: utf-8 -*-

# Be sure to restart your server when you modify this file.

default_secret = 'ops' * 30
secret_name = 'STAFF_PORTAL_SECRET'

if %w(development test ci).include?(Rails.env)
  NcsStaffPortal::Application.config.secret_token = ENV[secret_name] || default_secret
else
  NcsStaffPortal::Application.config.secret_token = ENV[secret_name] ||
    fail("#{secret_name} is mandatory for #{Rails.env}")
end
