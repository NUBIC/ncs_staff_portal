require 'fastercsv'

namespace :psu do
  desc "Loads the all SSU information for PSU.Please pass the path to file to load.e.g 'rake psu:load_ssu[path_to_file]'"
  task :load_ssu, :file, :needs=> :environment do |t, args|
    FILE = args[:file]
    raise "Please pass the absolute path to file with csv extension.e.g 'rake psu:load_ssu[path_to_file.csv]'" unless FILE
    FasterCSV.foreach("#{FILE}", :headers => true) do |csv|
      unless NcsSsu.find(:first, :conditions => {:psu_id  => csv["PSU_ID"], :ssu_id => csv["SSU_ID"], :ssu_name => csv["SSU_NAME"]})
        NcsSsu.create(:psu_id => csv["PSU_ID"], 
                      :ssu_id => csv["SSU_ID"],
                      :ssu_name => csv["SSU_NAME"],
                      :area => csv["AREA"])
      end
    end
  end
  
  desc "Loads the all TSU information for PSU.Please pass the path to file to load.e.g 'rake psu:load_tsu[path_to_file]'"
  task :load_tsu, :file, :needs=> :environment do |t, args|
    FILE = args[:file]
    raise "Please pass the absolute path to file with csv extension.e.g 'rake psu:load_tsu[path_to_file.csv]'" unless FILE
    FasterCSV.foreach("#{FILE}", :headers => true) do |csv|
      unless csv["TSU_ID"] == "."
        unless NcsTsu.find(:first, :conditions => {:psu_id  => csv["PSU_ID"], :tsu_id => csv["TSU_ID"], :tsu_name => csv["TSU_NAME"]})
           NcsTsu.create(:psu_id => csv["PSU_ID"], 
                         :tsu_id => csv["TSU_ID"],
                         :tsu_name => csv["TSU_NAME"],
                         :area => csv["AREA"])
         end
      end
    end
  end
end
