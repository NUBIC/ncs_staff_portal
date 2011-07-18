require 'ncs_navigator/mdes'

module StaffPortal
  class << self
    def config
      @config ||= YAML.load_file("/etc/nubic/ncs/staff_portal_config.yml")
    end
    
    def mdes
      @mdes ||= NcsNavigator::Mdes('2.0')
    end

    def configuration(sub)
      config[sub]
    end
  
    def study_center_id
      configuration('study_center')['id']
    end
  
    def study_center_name
      @study_center_name = mdes_label('study_center_cl1', study_center_id)
    end
    
    def psu_id
      configuration('psu')['id']
    end
  
    def psu_name
      @psu_name = mdes_label('psu_cl1', psu_id)
    end
    
    def display_username
      @display_username = configuration('display')['username']? configuration('display')['username'] : "Username" 
    end
    
    def display_footer_text
      configuration('display')['footer_text']
    end
    
    def mdes_label(list_name, id)
      mdes.types.find { |t| t.name == list_name }.code_list.find { |list| list.value == id.to_s }.label 
    end
  end
end