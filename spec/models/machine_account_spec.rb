require 'spec_helper'

describe MachineAccount do
  before do
    Role.create_all
  end

  describe '.find_by_username' do
    it 'returns a MachineAccount for "psc_application"' do
      MachineAccount.find_by_username('psc_application').should be_instance_of(MachineAccount)
    end

    describe 'given the Cases machine account username' do
      it 'returns a MachineAccount' do
        MachineAccount.find_by_username('ncs_navigator_cases_test').should be_instance_of(MachineAccount)
      end
    end

    it 'returns nil for an unrecognized input' do
      MachineAccount.find_by_username('foobar').should be_nil
    end

    it 'does not return non-machine accounts' do
      MachineAccount.find_by_username('staff').should be_nil
    end
  end

  describe '#can_see_staff?' do
    describe 'for the Ops -> PSC user' do
      let(:account) { MachineAccount.find_by_username('psc_application') }

      it 'returns true on anything' do
        account.can_see_staff?(double).should be_true
      end
    end

    describe 'for the Cases machine account' do
      let(:account) { MachineAccount.find_by_username('ncs_navigator_cases_test') }

      it 'returns true for itself' do
        staff = MachineAccount.find_by_username('ncs_navigator_cases_test')

        account.can_see_staff?(staff).should be_true
      end

      it 'returns false otherwise' do
        account.can_see_staff?(Staff.new).should be_false
      end
    end
  end
end
