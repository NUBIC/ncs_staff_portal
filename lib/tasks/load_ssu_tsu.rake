require 'fastercsv'
namespace :psu do
  desc "Loads the all areas for PSU and all SSUs for areas.Please pass the path to file to load.e.g 'rake psu:load_ncs_area_ssus[path_to_file]'"
  task :load_ncs_area_ssus, :file, :needs => :environment do |t, args|
    FILE = args[:file]
    raise "Please pass the absolute path to file with csv extension.e.g 'rake psu:load_ncs_area_ssus[path_to_file]'" unless FILE
    FasterCSV.foreach("#{FILE}", :headers => true) do |csv|
      unless NcsArea.find(:first, :conditions => {:psu_id  => StaffPortal.psu_id.to_s, :name => csv["AREA"]})
        NcsArea.create(:psu_id => StaffPortal.psu_id.to_s, 
                       :name => csv["AREA"])
      end
    end
    NcsArea.all.each do |area|
      FasterCSV.foreach("#{FILE}", :headers => true) do |csv|
        unless csv["AREA"] != area.name
          NcsAreaSsu.create(:ssu_id => csv["SSU_ID"], 
                       :ssu_name => csv["SSU_NAME"],
                       :ncs_area => area)
        end
      end
    end
  end
  
end
