require 'spec_helper'

describe OutreachEvent do
   describe "race attribute" do
     it "should create new outreach races if new_race_attributes" do
       @outreach = OutreachEvent.create
       @outreach.new_race_attributes = [HashWithIndifferentAccess.new({:race_code => 1})]
       @outreach.save
       @outreach.outreach_races.should have(1).race
       @outreach.outreach_races.first.race_code.should == 1
     end
     it "should create new outreach races if new_race_attributes with other" do
       @outreach = OutreachEvent.create
       @outreach.new_race_attributes = [HashWithIndifferentAccess.new({:race_code => -7, :race_other => "othertesting"})]
       @outreach.save
       @outreach.outreach_races.should have(1).race
       @outreach.outreach_races.first.race_code.should == -7
       @outreach.outreach_races.first.race_other.should == "othertesting"
     end
     
     it "should delete outreach races if race_attributes with should_destroy value true" do
        @outreach = OutreachEvent.create
        @outreach.new_race_attributes = [HashWithIndifferentAccess.new({:race_code => -7})]
        @outreach.save
        @race_to_delete_id = @outreach.outreach_races.first.id
        @outreach.outreach_races.should have(1).race
        @outreach.race_attributes = [HashWithIndifferentAccess.new({:race_code => -7, :id => @race_to_delete_id, :should_destroy => true})]
        @outreach.save
        @outreach.outreach_races.should have(0).race
        # @outreach.outreach_races.first.race_code.should == -7
        # @outreach.outreach_races.first.race_other.should == "othertesting"
      end
   end
end
