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
end
