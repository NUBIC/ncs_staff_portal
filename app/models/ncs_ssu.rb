class NcsSsu < ActiveRecord::Base
  def self.ssu_code_lookup
    NcsSsu.all.map do |s| 
      [s.ssu_name, s.ssu_id]
    end    
  end
end
