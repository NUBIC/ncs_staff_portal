require 'ncs_navigator/mdes' 
module MdesDataLoader 
  def self.load_codes_from_schema(version = '2.0') 
    mdes = NcsNavigator::Mdes(version) 
    counter = 0
    mdes.types.each do |type| 
    next if type.name.blank? 
      list_name = type.name.upcase # this is the code list name 
      if type.code_list 
        type.code_list.each do |code_list_entry| 
          ncs_code = NcsCode.find(:first, :conditions => { :list_name => list_name, :local_code => code_list_entry.value }) 
          if ncs_code.blank? 
            # unless code_list_entry.value == '-4' && code_list_entry.label == 'Missing in Error'
            counter += 1
            NcsCode.create(:list_name => list_name, :local_code => code_list_entry.value, :display_text => code_list_entry.label)
            # end
          end 
        end 
      end 
    end
    puts "Created #{counter} NcsCodes."
  end
end
