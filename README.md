Staff Portal
============

Staff Portal keeps track of the staff information including demographic information, time, hours, expenses. It also keeps track of all the outreach activities for the study center. Staff Portal is designed based of MDES documents of the National Children Study and currently pointing to the MDES version 2.0.

It is a Ruby on Rails application which uses Rails 3 and a PostgreSQL database.

Setup
-----

Staff Portal requires a few steps to get the data to start up:

### Prerequisites

#### Database setup 
Using [bcdatabase][] to configure the database for Staff Portal, you need to create file under `/etc/nubic/db`

   [bcdatabase]: https://github.com/NUBIC/bcdatabase/blob/master/README.markdown

*    Staging server, file name should be `ncsdb_staging.yml`

*    Production server, file name should be `ncsdb_prod.yml`

File should looks like, e.g

    ncs_staff_portal:
        adapter: postgresql                 # database adapter
        host: ncsdb-staging                 # database host
        port: 5432                          # database port
        database: staff_portal_staging      # database name
        username: staff_portal
        password: staff_portal
    
#### Authentication setup
Staff Portal uses [Aker-rails][] and [Aker][] for the authentication.

[Aker-rails]: https://github.com/NUBIC/aker-rails/blob/rails3/README.md
[Aker]: http://rubydoc.info/github/NUBIC/aker/master/file/README.md
            
Authentication setup has two steps.

1.    you need to create file under `/etc/nubic/ncs` for the cas setup.

     *   Staging server, file name should be `aker-staging.yml`

     *   Production server, file name should be `aker-prod.yml`

    File should looks like, e.g
        
        cas:
           base_url: https://rubycas-server/     # url to cas server
                  
2.    you need to create application users file `staff_portal_users.yml` under `/etc/nubic/ncs/`
        
     File should looks like, e.g

        groups: 
          StaffPortal: 
          - staff
          - supervisor
        users: 
          test1:    # username 
            first_name: firstname1
            last_name: lastname1
            email: test1@test.com
            portals: 
            - StaffPortal: 
              - staff
          test2:  # username 
            first_name: firstname2
            last_name: lastname2
            email: test2@test.com
            portals: 
            - StaffPortal: 
              - staff
          superuser:
            first_name: superuser
            last_name: superuser
            email: superuser@test.com
            portals: 
            - StaffPortal: 
              - staff
              - supervisor   # user has staff and supervisor role
        
#### Application configuration
To personalize Staff Portal, each deployment will have its own configuration file. 
    
You need to create configuration file `staff_portal_config.yml` under `/etc/nubic/ncs/`

File should looks like, e.g

    study_center:
      id: 1111 # Study center specific id
    psu:
      id: 1111 # psu id (Considering each study center have only one active psu)
    display:
      username: "Login name" # any username display other then default one 'Username'
      footer_text: 
        Sample Footer Text # any footer text specific to study center. If you have multiline text for footer, append '|' before the footer text
                               # e.g 
                               # footer_text:|
                               #       This is a multiline footer.
                               #       To preserve multiline, you need to add '|' before text.
                               #       This way you can have multiple lines in footer text.   
        
      footer_logo_front: "/staff_portal_images/footer_logo_front.png" # any footer logo you want to include before footer text
      footer_logo_back: "/staff_portal_images/footer_logo_back.png"   # any footer logo you want to include after footer text
    mail:
      smtp:                                      # smtp configuration for mail setup
          address: "example.smtp.com"
          port: 25
          domain: "example.com"
      host: "staging server/production server"   # host name 
      from: "NCS_Staff_Portal@example.com"       # from address to be included in email
      development:                               # if any development will be done,
          email: "user@example.com"              # developer's email address for development testing email
          
### Deployment
To deploy Staff Portal on server, machine(which will be used to deploy staff portal to server) should have its own configuration file for deploy.
    
You need to create configuration file `deploy_config.yml` under `/etc/nubic/db/`

File should looks like, e.g

    ncs_staff_portal:                                       
        repo: "git://github.com/NUBIC/ncs_staff_portal.git"            # github url for staff portal. This will be same all the time.
        deploy_to: "www/ncs_apps/"                                     # path on the server where application will be deploy   
        staging_app_server: "staging.server"                           # staging server name 
        production_app_server: "production.server"                     # production server name
        
After you check out the code, you need to deploy application on server.

    cap production deploy:migrations  # This will deploy application on production server. if deploying to staging, use 'cap staging deploy:migrations' instead.
            
### Rake tasks
There are many rake tasks which will load data into application. 

All the tasks should be executed from the application root on deploy server.

1.    `rake mdes:load_codes_from_schema_20` (This will load all the mdes codes into Staff Portal.)

2.    `rake users:load_to_portal` (This will load the all users specified in `/etc/nubic/ncs/staff_portal_users.yml` to the Staff Portal.)

3.    `rake psu:load_ncs_area_ssus[path_to_ssu_file]`

      This will load the all the areas and ssus of the psu into Staff Portal. File should be csv file with columns name as `AREA`, `SSU_ID`, `SSU_NAME` for the `psu:id` specified in `/etc/nubic/ncs/staff_portal_config.yml`

      The list defined in `AREA` will be displayed in Staff Portal and `SSU_NAME` will be used internally. If you want `SSU_NAME` being display in Staff Portal, please have `SSU_NAME` and `AREA` same.
      
4.    `rake giveaway_items:load_all[path_to_item_file]`

      This will load all the giveaway items for the outreach activities in the Staff Portal. File should be csv file with all items are listed under column `NAME`.
        
        
            
                
        