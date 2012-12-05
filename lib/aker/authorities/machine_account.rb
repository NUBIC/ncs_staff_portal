require 'aker'
require 'forwardable'
require 'stringio'

module Aker::Authorities
  ##
  # An authority that recognizes machine accounts.
  #
  # A machine account is an account used by NCS Navigator applications to
  # communicate with other applications in the suite.  Ops is responsible for
  # providing roles for those users.
  #
  # In that sense, they're a little bit like staff members, but the similarity
  # really ends there.
  #
  # This authority recognizes two users:
  #
  # 1. the PSC -> Ops user, which is currently hardcoded as "psc_application"
  # 2. the Cases -> PSC user, which is configured in the NCS Navigator
  #    configuration
  #
  # It supplies portal and role information for both users.
  class MachineAccount
    extend Forwardable

    attr_reader :static_auth

    def_delegators :static_auth, :find_users, :amplify!, :valid_credentials?

    ##
    # Name of the file containing machine account data.
    AUTH_FILE = File.expand_path('../machine_accounts.yml.erb', __FILE__)

    ##
    # We don't need to do anything with the configuration, so swallow it.
    def initialize(config)
      @static_auth = Aker::Authorities::Static.new(config)

      populate
    end

    ##
    # Loads authority data.  Usually called from the initializer, but can be
    # called from other contexts, i.e. tests.
    def populate
      data = ERB.new(File.read(AUTH_FILE), nil, '<>').result(binding)

      @static_auth.load!(StringIO.new(data))
    end

    ##
    # @private
    def cases_account_username
      Rails.application.config.ncs_navigator.core_machine_account_username
    end

    ##
    # @private
    def psc_user_password
      Rails.application.config.ncs_navigator.staff_portal['psc_user_password']
    end
  end
end
