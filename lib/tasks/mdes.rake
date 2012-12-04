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
  
  namespace :code_lists do
    task :base => :environment do
      require 'ncs_navigator/staff_portal/mdes_code_list_loader'
    end

    desc 'Generate the code list YAML file'
    task :yaml => :base do
      NcsNavigator::StaffPortal::MdesCodeListLoader.new(:interactive => true).create_yaml
      $stderr.puts "Code list YAML regenerated. Please verify and commit it."
    end

    desc 'Load the code lists into the ncs_codes table'
    task :load => :base do
      $stderr.puts "Tip: you can load all the seed data with db:seed."

      require 'benchmark'
      $stderr.puts(Benchmark.measure do
        NcsNavigator::StaffPortal::MdesCodeListLoader.new(:interactive => true).load_from_yaml
      end)
    end

    desc 'Counts the number of code list entries'
    task :count => :base do
      $stderr.puts "There are #{NcsCode.count} codes."
    end
  end

end
