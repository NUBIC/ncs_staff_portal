require 'ncs_navigator/configuration'

module NcsNavigator::StaffPortal
  ##
  # Exposes NCS Navigator configuration on the application's configuration
  # object.
  module Configuration
    class ConfigurationStub < BasicObject
      def from_file(file)
        @configuration = ::NcsNavigator::Configuration.new(file)
      end

      def load
        @configuration = ::NcsNavigator.configuration
      end

      def method_missing(method, *args, &block)
        @configuration.send(method, *args, &block)
      end
    end

    mattr_accessor :ncs_navigator

    self.ncs_navigator = ConfigurationStub.new
  end
end
