NCS Navigator Staff Portal
==========================

Staff Portal keeps track of the staff information including
demographic information, time, hours, expenses. It also keeps track of
all the outreach activities for the study center. Staff Portal's data
model is based on the Master Data Element Specification of the
National Children Study, version 2.0.

It is a Ruby on Rails application which uses Rails 3 and a PostgreSQL
database.

Prerequisites
-------------

On the deployment workstation:

* Ruby 1.8.7
* RubyGems
* [Bundler][] (install as a gem)
* A [git][] client

On the application server:

* Ruby 1.8.7 ([Ruby Enterprise Edition][ree] is what GCSC uses)
* RubyGems
* [Bundler][] (install as a gem)
* [Passenger][]
* A [git][] client
* Access to a PostgreSQL server

[Bundler]: http://gembundler.com/
[git]: http://git-scm.com/
[Passenger]: http://modrails.com/
[ree]: http://www.rubyenterpriseedition.com/

Setup
-----

### Configuration on the application server

#### Database setup

Staff Portal uses [bcdatabase][] to discover the database
configuration to use. Bcdatabase looks for a [YAML][] file with a
particular structure under `/etc/nubic/db`.

[bcdatabase]: https://github.com/NUBIC/bcdatabase/blob/master/README.markdown
[YAML]: http://yaml.org/

* For a staging deployment, the file name should be `/etc/nubic/db/ncsdb_staging.yml`
* For production, it should be `/etc/nubic/db/ncsdb_prod.yml`

Example:

    defaults:
      adapter: postgresql
      host: ncsdb-staging
      port: 5423
    ncs_staff_portal:
      database: staff_portal_staging   # database name
      username: staff_portal
      password: staff_portal

#### Authentication setup

Staff Portal uses [Aker-Rails][] and [Aker][] for authentication.

[Aker-Rails]: https://github.com/NUBIC/aker-rails/
[Aker]: http://rubydoc.info/github/NUBIC/aker/

Authentication setup has two steps.

1. Create file under `/etc/nubic/ncs` for the the central
   authentication parameters. These parameters will be used for all
   NCS Navigator applications on the same server.

     * In staging, the file name should be `aker-staging.yml`
     * In production, the file name should be `aker-prod.yml`

   Contents:

    cas:
      base_url: https://cas.myinst.edu/

2. Create application users file
   `/etc/nubic/ncs/staff_portal_users.yml`. The current version of
   Staff Portal uses statically configured users; a future version
   will rely on NCS Navigator suite-wide user provisioning.

   Example:

        groups:
          StaffPortal:
          - staff
          - supervisor
        users:
          jane:         # username
            first_name: Jane
            last_name: H
            email: jane@example.com
            portals:
            - StaffPortal:
              - staff
              - supervisor
          warren:
            first_name: Warren
            last_name: K
            email: warren@example.edu
            portals:
            - StaffPortal:
              - staff

#### Center-specific setup

To customize Staff Portal for your center, create a file named
`/etc/nubic/ncs/staff_portal_config.yml`.

Example:

    study_center:
      id: 1111 # Study center ID (from the MDES)
    psu:
      id: 1111 # Primary sampling unit ID (from the MDES)
    # Display customization. All these keys are optional.
    display:
      # The common name for the institutional user identity for this
      # center. E.g., at Northwestern calls this the "NetID". The
      # default is "Username"
      username: NetID
      # The text that should appear in the center of the footer on
      # each page. Note the '|' at the beginning -- this is necessary
      # if the text runs over multiple lines.
      footer_text: |+
        National Children’s Study - Greater Chicago Study Center
        Institute for Healthcare Studies, Feinberg School of Medicine
        Northwestern University
        420 East Superior, 10th Floor
        Chicago, IL 60611
      # Local file paths to files which should be used as the left and
      # right images in the footer.
      footer_logo_front: "/etc/nubic/ncs/staff_portal_images/footer_logo_front.png"
      footer_logo_back: "/etc/nubic/ncs/staff_portal_images/footer_logo_back.png"
    mail:
      smtp:                                    # SMTP configuration (to send e-mail)
          address: "example.smtp.com"
          port: 25
          domain: "example.com"
      host: "staging server/production server" # host name
      from: "NCS_Staff_Portal@example.com"     # from address to be included in email
      development:                             # if any development will be done,
        email: "user@example.com"              # developer's email address for development testing email

### Deployment

Staff Portal is deployed with [capistrano][cap] from a workstation. On
the workstation, you need to create a configuration file
`/etc/nubic/db/deploy_config.yml` to describe where it should be
deployed to.

[cap]: https://github.com/capistrano/capistrano/wiki/

Example:

    ncs_staff_portal:
      # Repository for staff portal. This will always be this value
      # same unless you wish to deploy your own fork.
      repo: "git://github.com/NUBIC/ncs_staff_portal.git"
      # path on the server where application will be deploy
      deploy_to: "/www/apps/"
      # staging server hostname
      staging_app_server: "staging.server"
      # production server hostname
      production_app_server: "production.server"

After you check out the code, run `bundle install` to install the gems
you'll need. Then deploy to the configured server:

    $ bundle exec cap production deploy:migrations

(This deploys to your production server; to deploy to staging instead,
substitute "staging" for "production".)

### Initialization

Staff Portal relies on many lists of data. It ships with [rake][]
tasks which will populate these lists from outside sources, usually
CSV files.

All the tasks should be executed from the application root on the
server where the application is deployed. Each one will need to be run
at least once for each environment in which Staff Portal is deployed.

[rake][]: http://rake.rubyforge.org/

#### Code lists

Initialize the code lists from the MDES using [ncs_mdes][]:

    $ rake mdes:load_codes_from_schema_20

[ncs_mdes]: https://github.com/NUBIC/ncs_mdes

#### Staff

Load all users as empty staff records:

    $ rake users:load_to_portal

This creates staff records for the users specified in
`/etc/nubic/ncs/staff_portal_users.yml`.

#### Secondary sampling units

Load SSUs:

    $ rake psu:load_ncs_area_ssus[/path/to/ssu-list.csv]

This creates SSU and area records that reflect the provided
spreadsheet in Staff Portal. The CSV's columns must be `AREA`,
`SSU_ID`, and `SSU_NAME`. `AREA` is the human-readable name for one or
more SSUs.

#### Giveaway items

Load giveaway items:

    $ rake giveaway_items:load_all[/path/to/giveaways.csv]

This will load all the giveaway items for the outreach activities in
the Staff Portal. The file must be a single column CSV file with all
items listed in the column `NAME`.
