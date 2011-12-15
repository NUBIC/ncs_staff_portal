require 'ncs_navigator/mdes'
require 'ncs_navigator/configuration'

module StaffPortal
	class << self

		def mdes
			@mdes ||= NcsNavigator::Mdes('2.0')
		end

		def configuration
			@configuration ||= NcsNavigator.configuration
		end

		def study_center_id
			configuration.sc_id
		end

		def study_center_name
			center_name = mdes_label('study_center_cl1', study_center_id)
			center_name ||= "Please define 'study_center_id' in navigator.ini"
			@study_center_name = center_name
			@study_center_name ||= "Study Center ID:#{study_center_id} not found!"
		end

		def psu_id
			configuration.psus.first.id unless NcsNavigator.configuration.psus.blank?
		end

		def psu_name
			@psu_name = mdes_label('psu_cl1', psu_id)
		end

		def footer_logo_left_path
			"config/" << configuration.footer_logo_left.to_s.split("/").last if configuration.footer_logo_left
		end

		def footer_logo_right_path
			"config/" << configuration.footer_logo_right.to_s.split("/").last if configuration.footer_logo_right
		end

		def development_email
			configuration.staff_portal['development_email']
		end

		private

		def mdes_label(list_name, id)
			# This search should gracefully fail.
			
			# attempting Ruby code equivalent of Groovy code:
			#   mdes.types.find{ it.name == list_name }?.code_list?.find{ it.value == id}?.label

			return_label = nil
			mdes_type = mdes.types.find { |t| t.name == list_name }
			if (mdes_type)
				code_list = mdes_type.code_list
				if (code_list)
					record = code_list.find { |list| list.value == id }
					if (record)
						return_label = record.label 
					end
				end
			end
			return return_label
		end
	end
end
