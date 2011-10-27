require 'spec_helper'

describe Staff do
  before(:each) do
    @user_admin =  Role.find_by_name(Role::USER_ADMINISTRATOR)
    @user_admin = FactoryGirl.create(:role, :name => "User Administrator") unless @user_admin
    
    @staff_supervisor = Role.find_by_name(Role::STAFF_SUPERVISOR)
    @staff_supervisor  = FactoryGirl.create(:role, :name => Role::STAFF_SUPERVISOR) unless @staff_supervisor 
  end
  
  
  describe "calculate_hourly_rate" do
    it "should put pay_amount as it is as hourly_rate if pay_type is 'Hourly'" do
      staff= FactoryGirl.build(:staff)
      staff.pay_type = "Hourly"
      staff.pay_amount = 25.00
      staff.save
      staff.hourly_rate.should == 25.00
    end
    
    it "should put pay_amount as 'amount/no.of hours worked in year' if pay_type is 'Yearly'" do
      staff= FactoryGirl.build(:staff)
      staff.pay_type = "Yearly"
      staff.pay_amount = 50000
      staff.save
      staff.hourly_rate.should == 28.57
    end
    
    it "should not calculate the hourly_rate if pay_amount is nil" do
      staff= FactoryGirl.build(:staff)
      staff.pay_type = "Yearly"
      staff.save
      staff.hourly_rate.should == 0
    end
    
    it "should not calculate the hourly_rate if pay_amount is nil" do
      staff= FactoryGirl.build(:staff)
      staff.pay_amount = 50000
      staff.save
      staff.hourly_rate.should == 0
    end
  end
  
  it { should have_many(:staff_roles) }
  it { should have_many(:roles).through(:staff_roles) }
  
  it { should have_many(:supervisor_employees) }
  it { should have_many(:employees).through(:supervisor_employees) }
  
  describe "weekly_task_reminder" do
    before(:each) do
      @staff1 = FactoryGirl.create(:staff)
      @staff2 = FactoryGirl.create(:staff)
      @staff3 = FactoryGirl.create(:staff)
      @staff4 = FactoryGirl.create(:staff)
    
      @staff3.staff_weekly_expenses.create(:week_start_date => Date.today.monday)
      @staff2.staff_weekly_expenses.create(:week_start_date => (Date.today - 1.week).monday)
      @staff1.staff_weekly_expenses.create(:week_start_date => (Date.today - 1.week).monday)
    end
    it "should return all the staff with no weekly task entry for the current week" do
      expected_staff = Staff.by_task_reminder(Date.today)
      expected_staff.should include @staff1
      expected_staff.should include @staff2
      expected_staff.should include @staff4
    end
    
    it "should return all the staff with no weekly task entry for the previous week" do
      expected_staff = Staff.by_task_reminder(Date.today - 1.week)
      expected_staff.should include @staff3
      expected_staff.should include @staff4
    end
  end
  
  describe "pay_amount" do
    it "should not contain other than decimal value" do
      staff= FactoryGirl.build(:staff)
      staff.pay_amount = "25,00"
      staff.should_not be_valid
      staff.should have(1).error_on(:pay_amount)
    end
    
    it "should be greater than 0 dollar" do
      staff= FactoryGirl.build(:staff)
      staff.pay_amount = -3
      staff.should_not be_valid
      staff.should have(1).error_on(:pay_amount)
    end
  end 
  
  describe "validates" do
    
    describe "staff_type" do
      let(:staff_type_code) { Factory(:ncs_code, :list_name => "STUDY_STAFF_TYPE_CL1", :display_text => "Other", :local_code => -5) }

      it "should not valid if staff type is 'Other' and staff_type_other value is nil" do
        staff = FactoryGirl.build(:staff, :staff_type => staff_type_code)
        staff.staff_type_other = nil
        staff.should_not be_valid
        staff.should have(1).error_on(:staff_type_other)
      end

      it "should not valid if staff type is 'Other' and staff_type_other value is blank string" do
        staff = FactoryGirl.build(:staff, :staff_type => staff_type_code)
        staff.staff_type_other = ''
        staff.should_not be_valid
        staff.should have(1).error_on(:staff_type_other)
      end

      it "should be valid if staff type is 'Principal Investigator' and staff_type_other value is blank string" do
        staff = FactoryGirl.build(:staff, :staff_type => Factory(:ncs_code, :list_name => "STUDY_STAFF_TYPE_CL1", :display_text => "Principal Investigator", :local_code => 1))
        staff.staff_type_other = ''
        staff.should be_valid
        staff.staff_type_other.should == nil
      end
    end
    
    describe "race" do
      let(:race_code) { Factory(:ncs_code, :list_name => "RACE_CL1", :display_text => "Other", :local_code => -5) }

      it "should not valid if staff race is 'Other' and race_other value is nil" do
        staff = FactoryGirl.build(:staff, :race => race_code)
        staff.race_other = nil
        staff.should_not be_valid
        staff.should have(1).error_on(:race_other)
      end

      it "should not valid if staff race is 'Other' and race_other value is blank string" do
        staff = FactoryGirl.build(:staff, :race => race_code)
        staff.race_other = ''
        staff.should_not be_valid
        staff.should have(1).error_on(:race_other)
      end

      it "should be valid if staff race is 'White' and race_other value is blank string" do
        staff = FactoryGirl.build(:staff, :race => Factory(:ncs_code, :list_name => "RACE_CL1", :display_text => "White", :local_code => 1))
        staff.race_other = ''
        staff.should be_valid
        staff.race_other.should == nil
      end
    end
    
    describe "presence" do
      it "first_name, last_name, email and studycenter is required if validate_create is not set" do
        staff = FactoryGirl.build(:staff, :username => "test123", :first_name => nil, :last_name => nil, :email => nil , :study_center => nil)
        staff.should_not be_valid
        staff.should have(1).error_on(:first_name)
        staff.should have(1).error_on(:last_name)
        staff.should have(1).error_on(:study_center)
      end
      
      it "staff_type, birth_date, gender, race, ethnicity, zipcode, subcontractor, experience is required if validate_update is not set" do
        staff = FactoryGirl.create(:staff)
        staff.save
        staff.should_not be_valid
        staff.should have(1).error_on(:staff_type)
        staff.should have(1).error_on(:birth_date)
        staff.should have(1).error_on(:gender)
        staff.should have(1).error_on(:race)
        staff.should have(1).error_on(:ethnicity)
        staff.should have(1).error_on(:zipcode)
        staff.should have(1).error_on(:subcontractor)
        staff.should have(1).error_on(:experience)
      end
      
      it "staff_type, birth_date, gender, race, ethnicity, zipcode, subcontractor, experience is not required if validate_update is false" do
        staff = FactoryGirl.create(:staff, :validate_update => "false")
        staff.save
        staff.should be_valid
      end
    end
  end
  
  describe "has_role" do
    before(:each) do
      @staff = FactoryGirl.create(:staff)
      @staff.roles << @user_admin
    end
    
    it "returns true if staff has particuler role" do
      @staff.has_role("User Administrator").should == true
    end
    
    it "returns false if staff has particuler role" do
      @staff.has_role("System Administrator").should == false
    end
  end
  
  describe "is_active" do
    before(:each) do
      @staff = FactoryGirl.create(:staff)
    end
    
    it "returns true if staff has ncs_inactive_date as nil" do
      @staff.is_active.should == true
    end
    
    it "returns true if staff has ncs_inactive_date as of today" do
      @staff.ncs_inactive_date = Time.now.to_date
      @staff.is_active.should == true
    end
    
    it "returns true if staff has ncs_inactive_date greater than today" do
      @staff.ncs_inactive_date = Time.now.to_date + 7.day
      @staff.is_active.should == true
    end
    
    it "returns false if staff has ncs_inactive_date less then today's date" do
      @staff.ncs_inactive_date = Time.now.to_date - 7.day
      @staff.is_active.should == false
    end
  end
  
  describe "supervisor employees" do
    before(:each) do
      @sup = FactoryGirl.create(:staff, :first_name => "Super Supervisor")
      @sup.roles << @staff_supervisor
      
      @sup1 = FactoryGirl.create(:staff, :first_name => "Supervisor")
      @sup1.roles << @staff_supervisor
      
      @staff1 = FactoryGirl.create(:staff)
      @staff2 = FactoryGirl.create(:staff)
      @staff3 = FactoryGirl.create(:staff)
      @sup1.employees = [@staff1, @staff2]
    end
    describe "default_supervisors" do
      it "returns the all the suervisor who has access to all employees" do
        actual_sup = Staff.default_supervisors
        actual_sup.should include @sup
      end
    
      it "does not include the supervisor who has employee assigned" do
        actual_sup = Staff.default_supervisors
        actual_sup.should_not include @sup1
      end
    end
    
    describe "visible_employees" do
      it "returns all the assigned employees for supervisor" do
        employees = @sup1.visible_employees
        employees.should include @staff1
        employees.should include @staff2
        employees.should_not include @staff3
      end
      
      it "returns all the employees if there is no assigned employee for supervisor" do
        employees = @sup.visible_employees
        employees.should include @staff1
        employees.should include @staff2
        employees.should include @staff3
      end
      
      it "returns empty array for staff other then supervisor" do
        other = FactoryGirl.create(:staff)
        employees = other.visible_employees
        employees.should be_empty
      end
    end
    
    describe "update_employees" do
      it "does nothing if staff has supervisor role" do
        @sup1.employees.should include @staff1
        @sup1.employees.should include @staff2
      end
      
      it "delete all the employees if staff doesn't have Staff Supervisor Role" do
        @sup1.validate_update = "false"
        @sup1.roles.delete_all 
        @sup1.save
        @sup1.employees.should be_empty
      end
    end
    
    describe "supervisors" do
      it "returns assigned supervisors" do
        supervisors = @staff1.supervisors
        supervisors.count.should == 1
        supervisors.should include @sup1
      end
      
      it "should not return un assigned supervisors" do
        supervisors = @staff1.supervisors
        supervisors.should_not include @sup
      end
    end
  end
 
  describe "as_json" do
    before(:each) do
      @staff = FactoryGirl.create(:staff)
    end
    
    ["username", "first_name", "last_name", "email", "study_center", "ncs_active_date", "ncs_inactive_date", "staff_type_other", "race_other"].each do |key|
      it "contains #{key}" do
        @staff.as_json.has_key?("#{key}").should == true
      end
    end
    
    ["pay_type", "pay_amount", "birth_date", "hourly_rate", "created_at", "updated_at", "comment", "staff_type_code", "age_range_code", "gender_code", "subcontractor_code", "ethnicity_code", "experience_code"].each do |key|
      it "does not contain #{key}" do
        @staff.as_json.has_key?("#{key}").should == false
      end
    end
    
    describe "contains staff_type" do
      it "key" do
        @staff.as_json.has_key?("staff_type").should == true
      end
      
      it "value to nil" do
        @staff.as_json["staff_type"].should == nil
      end
      
      it "value to actual display name" do
        Factory.create(:ncs_code, :list_name => "STUDY_STAFF_TYPE_CL1", :display_text => "Principal Investigator", :local_code => 1) 
        @staff.staff_type_code = 1
        actual_json = @staff.as_json
        actual_json["staff_type"].should == "Principal Investigator"
      end
    end
    
    describe "contains gender" do
      it "key" do
        @staff.as_json.has_key?("gender").should == true
      end
      
      it "value to nil" do
        @staff.as_json["gender"].should == nil
      end
      
      it "value to actual display name" do
        Factory.create(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Male", :local_code => 1) 
        @staff.gender_code = 1
        actual_json = @staff.as_json
        actual_json["gender"].should == "Male"
      end
    end
    
    describe "contains subcontractor" do
      it "key" do
        @staff.as_json.has_key?("subcontractor").should == true
      end
      
      it "value to nil" do
        @staff.as_json["subcontractor"].should == nil
      end
      
      it "value to actual display name" do
        Factory.create(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) 
        @staff.subcontractor_code = 1
        actual_json = @staff.as_json
        actual_json["subcontractor"].should == "Yes"
      end
    end
    
    describe "contains race" do
      it "key" do
        @staff.as_json.has_key?("race").should == true
      end
      
      it "value to nil" do
        @staff.as_json["race"].should == nil
      end
      
      it "value to actual display name" do
        Factory.create(:ncs_code, :list_name => "RACE_CL1", :display_text => "White", :local_code => 1) 
        @staff.race_code = 1
        actual_json = @staff.as_json
        actual_json["race"].should == "White"
      end
    end
    
    describe "contains ethinicity" do
      it "key" do
        @staff.as_json.has_key?("ethnicity").should == true
      end
      
      it "value to nil" do
        @staff.as_json["ethnicity"].should == nil
      end
      
      it "value to actual display name" do
        Factory.create(:ncs_code, :list_name => "ETHNICITY_CL1", :display_text => "Hispanic or Latino", :local_code => 1) 
        @staff.ethnicity_code = 1
        actual_json = @staff.as_json
        actual_json["ethnicity"].should == "Hispanic or Latino"
      end
    end
    
    describe "contains experience" do
      it "key" do
        @staff.as_json.has_key?("experience").should == true
      end
      
      it "value to nil" do
        @staff.as_json["experience"].should == nil
      end
      
      it "value to actual display name" do
        Factory.create(:ncs_code, :list_name => "EXPERIENCE_LEVEL_CL1", :display_text => "Less than 1 year", :local_code => 1) 
        @staff.experience_code = 1
        actual_json = @staff.as_json
        actual_json["experience"].should == "Less than 1 year"
      end
    end
    
    describe "contains roles" do
      it "key" do
        @staff.as_json.has_key?(:roles).should == true
      end
      
      it "should contain empty array if no roles assigned" do
        @staff.as_json[:roles].count.should == 0
      end
      
      it "should contain roles name for assigned roles" do
        @staff.roles << @user_admin
        @staff.roles << @staff_supervisor
        json_roles = @staff.as_json[:roles]
        json_roles.count.should == 2
        json_roles[0]["name"].should == "User Administrator"
        json_roles[1]["name"].should == "Staff Supervisor"
      end
    end
    
    describe "containd languages" do
      it "key" do
        @staff.as_json.has_key?("languages").should == true
      end
      
      it "should contain empty array if no languages assigned" do
        @staff.as_json["languages"].count.should == 0
      end
      
      it "should contain languages name for assigned roles" do
        @staff.staff_languages << FactoryGirl.create(:staff_language)
        json_languages = @staff.as_json["languages"]
        json_languages.count.should == 1
        json_languages[0]["name"].should == "English"
      end
    end
  end
end
