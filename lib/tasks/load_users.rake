require 'fastercsv'

namespace :users do
  desc 'Loads the application developers'
  task :load_devs => :environment do
    user_list = [


    ]
    staff_type = 13 # Informatics managment code as of MDES v1.2
    study_center = 20000029 # The NU study center ID as per MDES v1.2
    user_list.each do |u|
      Staff.create(:name => "#{u[0]} #{u[1]}", 
                   :netid => u[2],
                   :email => u[3],
                   :study_center => study_center,
                   :staff_type_code => staff_type)
    end
  end
  
  desc 'Loads the application users'
  task :load_users => :environment do
    FILE = 'NCS_initial_users.csv'
    raise "Please have FILE=<file_name>" unless FILE
    study_center = 20000029 # The NU study center ID as per MDES v1.2
    
    FasterCSV.foreach("#{RAILS_ROOT}/lib/#{FILE}", :headers => true) do |csv|
      Staff.create(:name => csv["NAME"], 
                   :netid => csv["NetID"],
                   :email => csv["EMAIL"],
                   :study_center => study_center)
     end
   end
   
   desc 'Loads the users into static auth file and assign default staff role'
   task :load_users_auth => :environment do
      users = Hash.new([])
      users_list = Hash.new([])
      Staff.all.sort_by(&:netid).each do |s|
        users[s.netid] = {"portals" => [{"StaffPortal" => ["staff"]}]}
      end
      users_list["groups"] = [{"StaffPortal" => ["staff","supervisor"]}]
      users_list["users"] = users

      AUTH_FILE = 'static-auth.yml'
      File.open("#{RAILS_ROOT}/lib/#{AUTH_FILE}", 'w') {|f| f.write(users_list.to_yaml) }
      
   end
  

end
