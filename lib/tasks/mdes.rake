require 'csv'

namespace :mdes do
  # MDES Version 1.2
  LOAD_FILE = 'MDES_V1.2-Specific_Code_Lists.csv'
  
  # MDES Version 2.0
  # LOAD_FILE = 'MDES_V2.0-Specific_Code_Lists.csv'

  desc 'loads MDES codes into the NcsCodes table'
  task :load_codes => :environment do
    # MDES Version 1.2
    require 'mdes_data_loader'
    MdesDataLoader::load_codes(LOAD_FILE)
    
    # MDES Version 2.0
    # require 'mdes_data_loader_2'
    # MdesDataLoader2::load_codes(LOAD_FILE)
  end

  desc 'outputs the count of ncs data elements'
  task :count_codes => :environment do 
    puts "There are #{NcsCode.count} codes"
  end

end
