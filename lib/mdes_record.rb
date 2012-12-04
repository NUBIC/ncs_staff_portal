require 'uuidtools'

##
# Extensions for models that map directly onto an MDES record.
#
# TODO: This is similar to, but simpler than, the same-named module in
# Core. At some point, they should be refactored out into a shared
# library (possibly ncs_mdes).
#
# One noteworthy difference: it uses `uuidtools` instead of `uuid` to
# generate UUIDs. `uuid` only supports type-1 UUIDs, which always
# include the source machine's MAC address. The way I'm planning to
# combine UUIDs for outreach export will create odd (ending in all
# zeros) UUIDs in this case. `uuidtools` supports type-4
# (pseudo-random) UUIDs, which will work better.
#
# TODO 2: The NcsCode stuff could similarly be cleaned up and shared.
module MdesRecord
  module ActsAsMdesRecord
    extend ActiveSupport::Concern

    ##
    # For migrations
    def self.create_public_id_string
      UUIDTools::UUID.random_create.to_s
    end

    included do
      # ID is generated as a side effect, if necessary
      after_initialize :public_id
    end

    module ClassMethods
      attr_accessor :public_id_attribute_name
      attr_accessor :attribute_names
    end

    class NcsCodedAttribute
      attr_reader :attribute_name, :list_name

      def initialize(model_class, attribute_name, list_name)
        @list_name = list_name.upcase
        @attribute_name = attribute_name.to_sym
        belongs_to!(model_class)
      end

      def foreign_key
        @foreign_key ||= "#{attribute_name}_code".to_sym
      end

      def belongs_to!(model)
        model.belongs_to(attribute_name,
          :conditions => "list_name = '#{list_name}'",
          :foreign_key => foreign_key,
          :class_name => 'NcsCode',
          :primary_key => :local_code)
      end
    end

    module InstanceMethods
      def public_id
        if v = self.send(self.class.public_id_attribute_name)
          v
        else
          generate_public_id
        end
      end

      def public_id=(value)
        self.send("#{self.class.public_id_attribute_name}=", value)
      end

      def get_attribute_names
        (self.attribute_names - ["id"]).sort
      end
      private :get_attribute_names

      def generate_public_id
        self.public_id = ActsAsMdesRecord.create_public_id_string
      end
      private :generate_public_id

    end
  end

  def acts_as_mdes_record(options)
    self.send(:include, ActsAsMdesRecord)
    self.public_id_attribute_name = options[:public_id]
  end

  def ncs_coded_attribute(attribute_name, list_name)
    ncs_coded_attributes[attribute_name.to_sym] =
      ::MdesRecord::ActsAsMdesRecord::NcsCodedAttribute.new(self, attribute_name, list_name)
  end

  def ncs_coded_attributes
    @ncs_coded_attributes ||= {}
  end
end

ActiveRecord::Base.send(:extend, MdesRecord)
