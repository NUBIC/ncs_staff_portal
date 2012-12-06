# == Schema Information
#
# Table name: management_tasks
#
#  id                      :integer         not null, primary key
#  staff_weekly_expense_id :integer
#  task_date               :date            not null
#  task_type_code          :integer         not null
#  task_type_other         :string(255)
#  hours                   :decimal(, )
#  expenses                :decimal(, )
#  miles                   :decimal(, )
#  comment                 :text
#  created_at              :datetime
#  updated_at              :datetime
#  staff_exp_mgmt_task_id  :string(36)      not null
#

require 'spec_helper'

describe ManagementTask do
  it "should create a new instance given valid attributes" do
    task = Factory(:management_task)
    task.should_not be_nil
  end

  it { should validate_presence_of(:task_type) }

  it { should belong_to(:staff_weekly_expense) }

  it { should belong_to(:task_type) }

  describe '#public_id' do
    it 'is :staff_exp_mgmt_task_id' do
      ManagementTask.new(:staff_exp_mgmt_task_id => 'fred').public_id.should == 'fred'
    end
  end

  describe "validations" do
    describe "hours" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:management_task, :hours => "test")
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end

      it "should not be greater than 99 hours" do
        task= FactoryGirl.build(:management_task, :hours => 100)
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end

      it "should be positive value" do
        task= FactoryGirl.build(:management_task, :hours => -3)
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end

      it "should allow value to be 0" do
        task= FactoryGirl.build(:management_task, :hours => 0)
        task.should be_valid
      end
    end

    describe "expenses" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:management_task, :expenses => "test")
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end

      it "should not be greater than 99999999.99" do
        task= FactoryGirl.build(:management_task, :expenses => 100000000)
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end

      it "should be positive value" do
        task= FactoryGirl.build(:management_task, :expenses => -3)
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end

      it "should allow value to be 0" do
        task= FactoryGirl.build(:management_task, :expenses => 0)
        task.should be_valid
      end
    end

    describe "miles" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:management_task, :miles => "test")
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end

      it "should not be greater than 999.99" do
        task= FactoryGirl.build(:management_task, :miles => 1000)
        task.miles = 1000
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end

      it "should be positive value" do
        task= FactoryGirl.build(:management_task, :miles => -3)
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end

      it "should allow value to be 0" do
        task= FactoryGirl.build(:management_task, :miles => 0)
        task.should be_valid
      end
    end

    describe "task_date" do
      it "should not be blank" do
        task= FactoryGirl.build(:management_task, :task_date => nil)
        task.should_not be_valid
        task.should have(1).error_on(:task_date)
      end
    end

    describe "task_type" do
      let(:task_type_code) { Factory(:ncs_code, :list_name => "STUDY_MNGMNT_TSK_TYPE_CL1", :display_text => "Other", :local_code => -5) }

      it "should not valid if management task is 'Other' and task_type_other value is nil" do
        management_task = FactoryGirl.build(:management_task, :task_type => task_type_code)
        management_task.task_type_other = nil
        management_task.should_not be_valid
        management_task.should have(1).error_on(:task_type_other)
      end

      it "should not valid if management task is 'Other' and task_type_other value is blank string" do
        management_task = FactoryGirl.build(:management_task, :task_type => task_type_code)
        management_task.task_type_other = ''
        management_task.should_not be_valid
        management_task.should have(1).error_on(:task_type_other)
      end

      it "should be valid if management task is 'NCS Management' and task_type_other value is blank string" do
        management_task = FactoryGirl.build(:management_task)
        management_task.task_type_other = ''
        management_task.should be_valid
        management_task.task_type_other.should == nil
      end
    end
  end
end
