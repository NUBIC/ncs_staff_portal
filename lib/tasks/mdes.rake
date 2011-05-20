require 'csv'

namespace :mdes do

  LOAD_FILE = 'MDES_V1.2-Specific_Code_Lists.csv'

  desc 'loads MDES codes into the NcsCodes table'
  task :load_codes => :environment do
    require 'mdes_data_loader'
    MdesDataLoader::load_codes(LOAD_FILE)
  end

  desc 'outputs the count of ncs data elements'
  task :count_codes => :environment do 
    puts "There are #{NcsCode.count} codes"
  end

end
