require 'mdes_data_loader'

namespace :mdes do
  desc 'loads 2.0 MDES codes from xsd'
  task :load_codes_from_schema_20 => :environment do
    MdesDataLoader::load_codes_from_schema('2.0')
  end

  desc 'Delete all existing codes and reloads 2.0 MDES codes from xsd'
  task :reload_codes_from_schema_20 => :environment do
    NcsCode.delete_all
    MdesDataLoader::load_codes_from_schema('2.0')
  end

  desc 'outputs the count of ncs data elements'
  task :count_codes => :environment do
    puts "There are #{NcsCode.count} codes"
  end

  desc 'loads 1.2 MDES codes from xsd'
  task :load_codes_from_schema_12 => :environment do
    MdesDataLoader::load_codes_from_schema('1.2')
  end

end
