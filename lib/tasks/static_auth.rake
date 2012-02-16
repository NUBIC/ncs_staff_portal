require 'ncs_navigator/configuration'

namespace :static_user do
  desc "create the static auth file with application user"
  task :create => :environment do
    psc_user_password = NcsNavigator.configuration.staff_portal['psc_user_password']
    raise "Please specify a psc user password (see README)." unless psc_user_password
    static_content = {}
    static_content["groups"] = { "NCSNavigator" => [ "Staff Supervisor" ]}
    static_content["users"] = { "psc_application" => { "portals" => [{ "NCSNavigator" => ["Staff Supervisor"]}],
                                "password" => psc_user_password }
                              }
    File.open("#{RAILS_ROOT}/lib/aker/static_auth.yml", 'w') {|f| f.write(static_content.to_yaml) }
  end
end