class NcsTsu < ActiveRecord::Base
  def self.tsu_code_lookup
    NcsTsu.all.map do |t| 
      [t.tsu_name, t.tsu_id]
    end    
  end
end
