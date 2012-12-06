# this will load our seed data to fix the fact that cucumber runs 'rake db:test:prepare' before all tests and blows away and seed data in there
require "#{Rails.root}/db/seeds.rb"
