require 'ncs_navigator/configuration'
namespace :psu do
  desc "Loads the ncs areas and ssus for psu of the studycenter"
  task :load_ncs_area_ssus => :environment do
    NcsNavigator.configuration.psus.each do |psu|
      NcsArea.all.each do |ncs_area|
        begin
          ncs_area.destroy unless psu.areas.map(&:name).include?(ncs_area.name)
        rescue Exception => e
          puts "Warning: #{ncs_area.name} is already used and can not be deleted. If you want to delete #{ncs_area.name}, delete all references of it from outreach events before."
        end
      end
      psu.areas.each do |area|
        unless NcsArea.find(:first, :conditions => {:psu_id  => psu.id, :name => area.name})
          ncs_area = NcsArea.create(:psu_id => psu.id, 
                                    :name => area.name)
          area.ssus.each do |ssu|
            NcsAreaSsu.create(:ssu_id => ssu.id, 
                              :ssu_name => ssu.name,
                              :ncs_area => ncs_area)
            
          end
        end
      end

    end
    puts "There are #{NcsArea.all.count} NcsAreas."
    puts "There are #{NcsAreaSsu.all.count} NcsAreaSsus."
  end
  
  task :load_ncs_ssus => :environment do
    NcsNavigator.configuration.psus.each do |psu|
      psu.areas.each do |area|
        area.ssus.each do |ssu|
          NcsSsu.create(:ssu_id => ssu.id, 
                        :ssu_name => ssu.name,
                        :psu_id => psu.id)
        end
      end
    end
    puts "There are #{NcsSsu.all.count} NcsSsus."
  end
end
