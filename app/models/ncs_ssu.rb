class NcsSsu < ActiveRecord::Base
  def self.ssu_code_lookup
    # Only First 15 rows for ssu information for now.
    NcsSsu.find(:all, :limit => 15).map do |s|
    # NcsSsu.all.map do |s| 
      [s.area, s.ssu_id]
    end    
  end
end
