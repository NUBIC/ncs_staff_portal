require 'ncs_navigator/configuration'
namespace :psu do
  desc "Loads the ncs areas and ssus for psu of the studycenter"
  task :load_ncs_area_ssus => :environment do
    NcsNavigator.configuration.psus.each do |psu|
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
    puts "Created #{NcsArea.all.count} NcsAreas."
    puts "Created #{NcsAreaSsu.all.count} NcsAreaSsus."
  end
end
