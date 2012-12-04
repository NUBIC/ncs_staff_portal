require 'ncs_navigator/staff_portal/warehouse'
# To preload the same version of the models used by Enumerator
require 'ncs_navigator/staff_portal/warehouse/enumerator'

require 'forwardable'

module NcsNavigator::StaffPortal::Warehouse
  ##
  # A utility that takes the entire contents of an MDES Warehouse
  # instance and initializes or updates this NCS Navigator Ops deployment's
  # operational tables to match its contents.
  #
  # The mappings from the MDES Warehouse to NCS Navigator Ops tables are defined in
  # {Enumerator}.
  class Importer
    extend Forwardable
    BLOCK_SIZE = 2500

    attr_reader :wh_config

    def_delegators self, :automatic_producers
    def_delegators :wh_config, :shell, :log

    def initialize(wh_config)
      @wh_config = wh_config
      @staff_portal_models_indexed_by_table = {}
      @public_id_indexes = {}
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
      Enumerator.record_producers.reject { |rp| rp.name.to_s == "outreach_untailored_automatic" || rp.name.to_s == "staff_languages_other" }
    end

    private

    def create_simply_mapped_staff_portal_records(mdes_producer)
      staff_portal_model = staff_portal_model_for_table(mdes_producer.name)
      mdes_model = mdes_producer.model(wh_config)
      count = mdes_model.count
      offset = 0
      while offset < count
        staff_portal_model.transaction do
          mdes_model.all(:limit => BLOCK_SIZE, :offset => offset).each do |mdes_record|
            staff_portal_record = apply_mdes_record_to_staff_portal(staff_portal_model, mdes_record)

            case mdes_producer.name
            when :staff
              staff_portal_record.send("validate_update=", "false")
              staff_portal_record.send("age_group_code=", mdes_record.staff_age_range)
              staff_portal_record.send("external=", true)
              staff_portal_record.send("notify=", false)
              staff_portal_record.send("ncs_inactive_date=", Date.today)
              [
                ["staff_type_code", "staff_type_other"], ["race_code", "race_other"]
              ].each do |code_attribute_name, other_attribute_name|
                staff_portal_record = apply_other_value(staff_portal_record, code_attribute_name, other_attribute_name)
              end
            when :staff_languages
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
              staff_portal_record = apply_other_value(staff_portal_record, "lang_code", "lang_other")
            when :staff_cert_trainings
              staff_portal_record.send("expiration_date=", mdes_record.send("cert_type_exp_date"))
            when :staff_weekly_expenses
              [
                ["staff_hours", "hours"], ["staff_expenses", "expenses"], ["staff_miles", "miles"]
              ].each do |mdes_variable, staff_portal_attribute|
                staff_portal_record.send("#{staff_portal_attribute}=", mdes_record.send(mdes_variable))
              end
            when :management_tasks, :data_collection_tasks
              mdes_variable = mdes_producer.name == :management_tasks ? "mgmt_task_hrs" : "data_coll_tasks_hrs"
              staff_portal_record.send("hours=", mdes_record.send(mdes_variable))
              staff_portal_record.send("task_date=", staff_portal_record.staff_weekly_expense.week_start_date)
              staff_portal_record = apply_other_value(staff_portal_record, "task_type_code", "task_type_other")
            when :outreach_events
              [
                ["outreach_lang1", "language_specific_code"], ["outreach_race1", "race_specific_code"],
                ["outreach_culture1", "culture_specific_code"], ["outreach_culture2", "culture_code"],
                ["outreach_eval_result", "evaluation_result_code"], ["outreach_staffing", "no_of_staff"],
                ["outreach_quantity", "attendees_quantity"], ["outreach_event_id", "source_id"]
              ].each do |mdes_variable, staff_portal_attribute|
                staff_portal_record.send("#{staff_portal_attribute}=", mdes_record.send(mdes_variable))
              end
              staff_portal_record.send("import=", "true")
              staff_portal_record.send("name=", "Imported to the system")
              [
                ["mode_code", "mode_other"], ["outreach_type_code", "outreach_type_other"], ["culture_code", "culture_other"]
              ].each do |code_attribute_name, other_attribute_name|
                staff_portal_record = apply_other_value(staff_portal_record, code_attribute_name, other_attribute_name)
              end
            when :outreach_languages
              outreach_event = wh_config.model(:Outreach).all(:outreach_event_id => staff_portal_record.outreach_event.outreach_event_id).first
              staff_portal_record.send("language_other=", outreach_event.outreach_lang_oth)
              staff_portal_record.send("source_id=", mdes_record.send("outreach_lang2_id"))
              staff_portal_record = apply_other_value(staff_portal_record, "language_code", "language_other")
            when :outreach_races
              staff_portal_record.send("source_id=", mdes_record.send("outreach_race_id"))
              staff_portal_record = apply_other_value(staff_portal_record, "race_code", "race_other")
            when :outreach_targets
              staff_portal_record.send("source_id=", mdes_record.send("outreach_target_id"))
              staff_portal_record = apply_other_value(staff_portal_record, "target_code", "target_other")
            when :outreach_evaluations
              staff_portal_record.send("source_id=", mdes_record.send("outreach_event_eval_id"))
              staff_portal_record = apply_other_value(staff_portal_record, "evaluation_code", "evaluation_other")
            when :outreach_staff_members
              staff_portal_record.send("source_id=", mdes_record.send("outreach_event_staff_id"))
            end

            staff_portal_record = save_staff_portal_record_with_mode(staff_portal_record, staff_portal_model)
            if mdes_producer.name == :outreach_events
              ssu_id = mdes_record.send("ssu_id")
              ncs_ssu = NcsSsu.find_by_ssu_id(ssu_id)
              unless ncs_ssu
                raise "There is no NcsSsu created with ssu_id = #{ssu_id}. Please load the NcsSsu first and then try import again."
              end
              outreach_segment = OutreachSegment.new(:ncs_ssu => ncs_ssu, :outreach_event => staff_portal_record)
              tsu_id = mdes_record.send("tsu_id")
              if tsu_id
                ncs_tsu = NcsTsu.find_by_tsu_id(tsu_id)
                outreach_segment.ncs_tsu = ncs_tsu
              end
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
    # @return a NCS Navigator Ops record corresponding to the MDES record. It may
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
            (staff_portal_attribute.scan /^public_id_for_(.*)$/).first.first
          if associated_table.to_s != "this_table"
            staff_portal_model_association_id = associated_table.to_s.singularize + "_id"
            associated_model = staff_portal_model_for_table(associated_table)
            associated_public_id = mdes_record.send(mdes_variable)
            new_association_id = public_id_index(associated_model)[associated_public_id]
            staff_portal_record.send("#{staff_portal_model_association_id}=", new_association_id)
          end

          if associated_table.to_s == "this_table"
            staff_portal_record.send("#{mdes_variable}=", mdes_record.send(mdes_variable))
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
        find_producer(staff_portal_model.table_name).column_map(staff_portal_model.column_names, wh_config)
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

    def apply_other_value(staff_portal_record, code_attribute_name, other_attribute_name)
      if staff_portal_record.send("#{code_attribute_name}") == -5 && staff_portal_record.send("#{other_attribute_name}").blank?
        staff_portal_record.send("#{other_attribute_name}=", "Missing in Error - Other value")
      end
      staff_portal_record
    end

  end
end
