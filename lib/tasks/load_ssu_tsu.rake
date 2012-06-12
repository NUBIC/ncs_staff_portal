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
            ncs_ssu = NcsSsu.find_by_ssu_id(ssu.id)
            if !ncs_ssu.blank?
              unless NcsAreaSsu.find(:first, :conditions => {:ncs_ssu_id  => ncs_ssu.id, :ncs_area_id => ncs_area.id})
                NcsAreaSsu.create(:ncs_ssu => ncs_ssu,
                              :ncs_area => ncs_area)
              end
            end
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
          unless NcsSsu.find(:first, :conditions => {:ssu_id  => ssu.id})
            NcsSsu.create(:ssu_id => ssu.id,
                        :ssu_name => ssu.name,
                        :psu_id => psu.id)
          end
        end
      end
    end
    puts "There are #{NcsSsu.all.count} NcsSsus."
  end
  
  task :load_ncs_tsus => :environment do
    NcsNavigator.configuration.psus.each do |psu|
      psu.areas.each do |area|
        area.ssus.each do |ssu|
          ssu.tsus.each do |tsu|
            if tsu.id != "."
              unless NcsTsu.find(:first, :conditions => {:tsu_id  => tsu.id})
                NcsTsu.create(:tsu_id => tsu.id,
                          :tsu_name => tsu.name,
                          :psu_id => psu.id)
              end
            end
          end
        end
      end
    end
    puts "There are #{NcsTsu.all.count} NcsTsus."
  end
end
