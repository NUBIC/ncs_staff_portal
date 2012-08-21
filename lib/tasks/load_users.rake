require 'csv'

namespace :users do
  desc "loads the new users from csv file into application. if staff_id is specified, then maps staff_id to username and updates the staff attribute."
  task :load, [:file] => [:environment] do |t, args|
    FILE = args[:file]
    raise "Please pass the path to file with csv extension.e.g 'rake users:load_to_file[path_to_file]'" unless FILE
    counter = 0
    CSV.foreach("#{FILE}", :headers => true) do |csv|
      if csv["STAFF_ID"]
        staff = Staff.find_by_staff_id(csv["STAFF_ID"])
        if staff
          [
            ["first_name", csv["FIRST_NAME"]], ["last_name", csv["LAST_NAME"]], 
            ["username", csv["USERNAME"]], ["email", csv["EMAIL"]],
            ["study_center", StaffPortal.study_center_id], ["validate_update", "false"]
          ].each do |staff_portal_attribute, csv_record|
            staff.send("#{staff_portal_attribute}=", csv_record)
          end
          staff.save!
          counter += 1
        else
          raise "No staff record found with the Staff_Id = #{csv["STAFF_ID"]}. Please make sure Staff_Id is correct."
        end
      else
        unless Staff.find(:first, :conditions => {:username => csv["USERNAME"]})
          Staff.create( :first_name => csv["FIRST_NAME"], 
                        :last_name => csv["LAST_NAME"],
                        :username => csv["USERNAME"],
                        :email => csv["EMAIL"],
                        :study_center => StaffPortal.study_center_id)
          counter += 1
        end
      end
    end
    unless counter == 0
      if counter == 1 
        puts "#{counter} user is added/updated to the NCS Navigator Ops"
      elsif
        puts "#{counter} users are added/updated to the NCS Navigator Ops"
      end
    end
  end
end

