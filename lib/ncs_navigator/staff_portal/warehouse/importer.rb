require 'ncs_navigator/staff_portal/warehouse'
# To preload the same version of the models used by Enumerator
require 'ncs_navigator/staff_portal/warehouse/enumerator'

require 'forwardable'

module NcsNavigator::StaffPortal::Warehouse
  ##
  # A utility that takes the entire contents of an MDES Warehouse
  # instance and initializes or updates this Staff Portal deployment's
  # operational tables to match its contents.
  #
  # The mappings from the MDES Warehouse to Staff Portal tables are defined in
  # {Enumerator}.
  class Importer
    extend Forwardable
    include NcsNavigator::Warehouse::Models::TwoPointZero
    BLOCK_SIZE = 2500

    attr_reader :wh_config

    def_delegators self, :automatic_producers
    def_delegators :wh_config, :shell, :log

    def initialize(wh_config)
      @wh_config = wh_config
      @staff_portal_models_indexed_by_table = {}
      @public_id_indexes = {}
      @failed_associations = []
    end
    
    def import(*tables)
      begin
        automatic_producers.
          select { |rp| tables.empty? || tables.include?(rp.name) }.
          each do |one_to_one_producer|
            create_simply_mapped_staff_portal_records(one_to_one_producer)
          end
      ensure
      end
    end

    def self.automatic_producers
      Enumerator.record_producers.reject { |rp|
        %w(outreach_untailored_automatic).include?(rp.name.to_s) 
      }
    end
    
    private
    
    def create_simply_mapped_staff_portal_records(mdes_producer)
      staff_portal_model = staff_portal_model_for_table(mdes_producer.name)
      mdes_model = mdes_producer.model
      count = mdes_model.count
      offset = 0
      while offset < count 
        staff_portal_model.transaction do
          mdes_model.all(:limit => BLOCK_SIZE, :offset => offset).each do |mdes_record|
            staff_portal_record = apply_mdes_record_to_staff_portal(staff_portal_model, mdes_record)
            if mdes_producer.name == :staff
              staff_portal_record.send("validate_update=", "false")
              staff_portal_record.send("age_group_code=", mdes_record.staff_age_range)
              staff_portal_record.send("zipcode=", mdes_record.staff_zip.to_i)
            end
            
            if mdes_producer.name == :staff_languages  
              mdes_value = mdes_record.send("staff_lang_oth")
              if mdes_value && mdes_value =~ /,/
                mdes_values = mdes_value.split(",")
                no_of_new_records = mdes_values.size
                count = 1;
                staff_portal_record.send("lang_other=", mdes_values[0])
                until count == no_of_new_records
                  new_record = staff_portal_model.new(staff_portal_record.attributes)
                  new_record.send("staff_language_id=", MdesRecord::ActsAsMdesRecord.create_public_id_string)
                  new_record.send("lang_other=", mdes_values[count])
                  save_staff_portal_record_with_mode(new_record, staff_portal_model)
                  count += 1
                end
              end
            end
            
            if mdes_producer.name == :staff_weekly_expenses
              miscellaneous_expense = MiscellaneousExpense.new
              [
                ["week_start_date", "expense_date"], ["staff_expenses", "expenses"], ["staff_miles", "miles"]
              ].each do |mdes_variable, staff_portal_attribute|
                miscellaneous_expense.send("#{staff_portal_attribute}=", mdes_record.send(mdes_variable))
              end
              miscellaneous_expense.send("comment=", "Imported to staff portal")
              save_staff_portal_record_with_mode(miscellaneous_expense, staff_portal_model)
            end
            
            if mdes_producer.name == :management_tasks || mdes_producer.name == :data_collection_tasks
              mdes_variable = mdes_producer.name == :management_tasks ? "mgmt_task_hrs" : "data_coll_tasks_hrs"
              staff_portal_record.send("hours=", mdes_record.send(mdes_variable))
              staff_portal_record.send("task_date=", staff_portal_record.staff_weekly_expense.week_start_date)
            end
          
            if mdes_producer.name == :outreach_events
              [
                ["outreach_lang1", "language_specific_code"], ["outreach_race1", "race_specific_code"], 
                ["outreach_culture1", "culture_specific_code"], ["outreach_culture2", "culture_code"],
                ["outreach_eval_result", "evaluation_result_code"], ["outreach_staffing", "no_of_staff"]
              ].each do |mdes_variable, staff_portal_attribute|
                staff_portal_record.send("#{staff_portal_attribute}=", mdes_record.send(mdes_variable))
              end
              staff_portal_record.send("import=", "true")
              staff_portal_record.send("name=", "Imported to staff portal")
            end
            
            if mdes_producer.name == :outreach_languages
               outreach_event = Outreach.all(:outreach_event_id => staff_portal_record.outreach_event.outreach_event_id).first
               staff_portal_record.send("language_other=", outreach_event.outreach_lang_oth)
            end
            staff_portal_record = save_staff_portal_record_with_mode(staff_portal_record, staff_portal_model)
            if mdes_producer.name == :outreach_events
              ssu_id = mdes_record.send("ssu_id")
              ncs_area = NcsAreaSsu.find_by_ssu_id(ssu_id).ncs_area
              outreach_segment = OutreachSegment.new(:ncs_area => ncs_area, :outreach_event => staff_portal_record)
              save_staff_portal_record_with_mode(outreach_segment, OutreachSegment)
            end
          end
        end
        offset += BLOCK_SIZE
      end
    end
    
    def save_staff_portal_record_with_mode(staff_portal_record, staff_portal_model)
      if staff_portal_model.respond_to?(:importer_mode)
        staff_portal_model.importer_mode { save_staff_portal_record(staff_portal_record) }
      else
        save_staff_portal_record(staff_portal_record)
      end
    end
    # @return a staff portal record corresponding to the MDES record. It may
    #   or may not be a record that already exists in core. Whether or
    #   not it is, it will have been sync'd with the input MDES record
    #   but not saved.
    def apply_mdes_record_to_staff_portal(staff_portal_model, mdes_record)
      mdes_key = mdes_record.key.first
      staff_portal_record =
        if existing_id = public_id_index(staff_portal_model)[mdes_key]
          staff_portal_model.find(existing_id)
        else
          staff_portal_model.new
        end
      column_map(staff_portal_model).each do |staff_portal_attribute, mdes_variable|
        if staff_portal_attribute =~ /^public_id_for_/
          associated_table=
            (staff_portal_attribute.scan /^public_id_for_(.*)$/).first
          if associated_table.to_s != "this_table"
            staff_portal_model_association_id = associated_table.to_s.singularize + "_id"
            associated_model = staff_portal_model_for_table(associated_table)
            associated_public_id = mdes_record.send(mdes_variable)
            new_association_id = public_id_index(associated_model)[associated_public_id]
            staff_portal_record.send("#{staff_portal_model_association_id}=", new_association_id)
          end
        elsif staff_portal_attribute =~ /_code$/
          mdes_value = mdes_record.send(mdes_variable)
          if mdes_value
            code_attribute_name = staff_portal_attribute.sub(/_code$/, '').to_sym
            code_attribute = staff_portal_model.ncs_coded_attributes[code_attribute_name]
            staff_portal_code = ncs_code_object_for(mdes_value, code_attribute.list_name)
            if staff_portal_code
              staff_portal_record.send("#{code_attribute_name}=", staff_portal_code)
            else
              staff_portal_record.send("#{staff_portal_attribute}=", mdes_value)
            end
          else
            staff_portal_record.send("#{staff_portal_attribute}=", mdes_record.send(mdes_variable))
          end
        else
          staff_portal_record.send("#{staff_portal_attribute}=", mdes_record.send(mdes_variable))
        end
      end
      staff_portal_record
    end

    def save_staff_portal_record(staff_portal_record)
      ident = "#{staff_portal_record.class}##{staff_portal_record.id}"
      ident << "##{staff_portal_record.public_id}" if staff_portal_record.class.method_defined? :public_id
      if staff_portal_record.new_record?
        log.debug("Creating #{ident}: #{staff_portal_record.inspect}.")
      elsif staff_portal_record.changed?
        log.debug("Updating #{ident} with #{staff_portal_record.changes.inspect}.")
      else
        log.debug("#{ident} encountered; no differences.")
      end
      staff_portal_record.save!
      public_id_index(staff_portal_record.class)[staff_portal_record.public_id] = staff_portal_record.id if staff_portal_record.class.method_defined? :public_id
      staff_portal_record
    end
    
    def find_producer(name)
      Enumerator.record_producers.find { |rp| rp.name.to_sym == name.to_sym }
    end

    def column_map(staff_portal_model)
      column_maps[staff_portal_model] ||=
        find_producer(staff_portal_model.table_name).column_map(staff_portal_model.column_names)
    end

    def column_maps
      @column_maps ||= {}
    end


    def staff_portal_model_for_table(name)
      name = name.to_s
      @staff_portal_models_indexed_by_table[name] ||= Object.const_get(name.singularize.camelize)
    end    
    
    def public_id_index(staff_portal_model)
      @public_id_indexes[staff_portal_model.table_name] ||= build_public_id_index(staff_portal_model)
    end

    def build_public_id_index(staff_portal_model)      
      index_query =
        "SELECT id, #{staff_portal_model.public_id_attribute_name} AS public_id FROM #{staff_portal_model.table_name}"
      ActiveRecord::Base.connection.
        select_all(index_query).
        inject({}) do |idx, row|
        idx[row['public_id']] = row['id']
        idx
      end
    end
    
    def ncs_code_object_for(local_code, list_name)
      ncs_code_list(list_name).detect { |cl| cl.local_code == local_code.to_i }
    end

    def ncs_code_list(list_name)
      ncs_code_lists[list_name] ||= build_ncs_code_list(list_name)
    end

    def build_ncs_code_list(list_name)
      NcsCode.find_all_by_list_name(list_name)
    end

    def ncs_code_lists
      @ncs_code_lists ||= {}
    end
  end
end