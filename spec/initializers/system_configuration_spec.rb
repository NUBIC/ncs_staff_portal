require 'spec_helper'
require 'ncs_navigator/mdes'

describe StaffPortal do
  describe '#mdes' do
    before do
      StaffPortal.mdes_version = '2.0'
    end

    it 'is a Specification' do
      StaffPortal.mdes.should be_a NcsNavigator::Mdes::Specification
    end
  end
end