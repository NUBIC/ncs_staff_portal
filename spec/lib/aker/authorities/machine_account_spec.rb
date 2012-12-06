require 'spec_helper'

require 'aker/authorities/machine_account'

module Aker::Authorities
  describe MachineAccount do
    let(:config) { Aker::Configuration.new }
    let(:authority) { MachineAccount.new(config) }

    around do |example|
      begin
        u = NcsNavigator.configuration.core_machine_account_username
        NcsNavigator.configuration.core_machine_account_username = 'ncs_navigator_cases_test'
        example.call
      ensure
        NcsNavigator.configuration.core_machine_account_username = u
      end
    end

    before do
      authority.populate
    end

    describe '#find_users' do
      describe 'given the PSC -> Ops username' do
        it 'returns a single user' do
          authority.find_users('psc_application').length.should == 1
        end
      end

      describe 'given the Cases -> PSC username' do
        it 'returns a single user' do
          authority.find_users('ncs_navigator_cases_test').length.should == 1
        end
      end

      describe 'given an unrecognized username' do
        it 'returns []' do
          authority.find_users('foobar').should be_empty
        end
      end

      describe 'given no criteria' do
        it 'returns []' do
          authority.find_users.should be_empty
        end
      end
    end

    describe '#amplify!' do
      let(:roles) { user.group_memberships(:NCSNavigator) }
      let(:user) { authority.find_users(username).first }

      before do
        authority.amplify!(user)
      end

      describe 'with the PSC -> Ops user' do
        let(:username) { 'psc_application' }

        it 'adds the Staff Supervisor role' do
          roles.should include(Role::STAFF_SUPERVISOR)
        end

        it 'adds the User Administrator role' do
          roles.should include(Role::USER_ADMINISTRATOR)
        end

        it 'has a numeric ID' do
          user.identifiers[:numeric_id].should be_instance_of(Fixnum)
        end
      end

      describe 'with the Cases -> PSC user' do
        let(:username) { 'ncs_navigator_cases_test' }

        it 'has the Field Staff role' do
          roles.should include(Role::FIELD_STAFF)
        end

        it 'has the Phone Staff role' do
          roles.should include(Role::PHONE_STAFF)
        end

        it 'has a numeric ID' do
          user.identifiers[:numeric_id].should be_instance_of(Fixnum)
        end
      end
    end
  end
end
