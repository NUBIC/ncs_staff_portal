require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal::Warehouse
  ##
  # An "importer" that skips importing. Instead, it copies all the
  # tables that SP cares about into a VDR-formatted XML file in the
  # `importer_passthrough` directory. This file can then be included
  # in the warehouse ETL process alongside the SP transformer to merge
  # old and new data in the reported file.
  #
  # This class is very similar to the "unused" table passthroughs in
  # NCS Navigator Core. The difference is that this passthrough is an
  # alternative to doing a NCS Navigator Ops import rather than a
  # complement for preserving data that isn't imported in a normal
  # import.
  class NotImportedPassthrough
    include XmlPassthrough

    def filename
      'outside_staff'
    end

    def passthrough_tables
      Enumerator.record_producers.
        select { |rp| rp.respond_to?(:model) }.collect(&:model).collect(&:mdes_table_name).uniq
    end
  end
end
