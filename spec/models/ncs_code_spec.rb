# == Schema Information
#
# Table name: ncs_codes
#
#  id           :integer         not null, primary key
#  list_name    :string(255)     not null
#  display_text :string(255)     not null
#  local_code   :integer         not null
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe NcsCode do
  describe "class methods" do
    describe "ncs_code_lookup" do
      before (:each) do
        @ncs_codes = [
          NcsCode.new(:list_name => 'TEST_CODE_CL1', :local_code =>1, :display_text =>'A'),
          NcsCode.new(:list_name => 'TEST_CODE_CL1', :local_code =>2, :display_text =>'B'),
          NcsCode.new(:list_name => 'TEST_CODE_CL1', :local_code =>3, :display_text =>'C')
          ]
        @ncs_return_code = [
          ['A', 1],
          ['B', 2],
          ['C', 3],
          ]
        NcsCode.should_receive(:attribute_lookup).with(:test_code).and_return("TEST_CODE_CL1")
        NcsCode.should_receive(:find_all_by_list_name).with("TEST_CODE_CL1").and_return(@ncs_codes)
      end
    
      it "should return an array of integer and string for attributes" do
        test_type = NcsCode.ncs_code_lookup(:test_code)
        test_type.is_a?(Array).should be_true
        test_type.first[0].is_a?(String).should be_true 
        test_type.first[1].is_a?(Integer).should be_true
      end
    
      it "should return code and text for given attribute list" do
        test_type = NcsCode.ncs_code_lookup(:test_code)
        @ncs_return_code.each_with_index do |code, i|
          code[0].should == test_type[i][0]
          code[1].should == test_type[i][1]
        end
      end
    end 
    describe "attribute_lookup" do
      it "should return corresponding list name for attribute name" do
        staff_type_list  = NcsCode.attribute_lookup(:staff_type_code)
        staff_type_list.should == 'STUDY_STAFF_TYPE_CL1'
      end
    end
  end
end
