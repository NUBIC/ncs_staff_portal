# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# MDES Version 1.2
# require 'mdes_data_loader'
# Our custom data seed loader
# MdesDataLoader::load_codes('MDES_V1.2-Specific_Code_Lists.csv')

# #MDES Version 2.0
# require 'mdes_data_loader'
# # Our custom data seed loader
# MdesDataLoader::load_codes_from_schema('2.0')

if ENV['INITIAL_MDES_VERSION']
  MdesVersion.set!(ENV['INITIAL_MDES_VERSION'])
end

require 'ncs_navigator/staff_portal/mdes_code_list_loader'
NcsNavigator::StaffPortal::MdesCodeListLoader.new(:interactive => true).load_from_yaml

Role.create_all
