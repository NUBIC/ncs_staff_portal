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

* RVM
* Ruby 1.8.7
* RubyGems
* [Bundler][] (install as a gem)
* A [git][] client

Ubuntu (11.04) package prerequisites:

	$ sudo apt-get install ruby postgresql zlib1g-dev libssl-dev libreadline6-dev libxml2-dev libxslt-dev libpq-dev


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
[rvm]: http://beginrescueend.com/

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
* For developement, it should be `/etc/nubic/db/local_postgresql.yml`

Example:

    defaults:
      adapter: postgresql
      host: ncsdb-staging
      port: 5432
    ncs_staff_portal:
      database: staff_portal_staging   # database name
      username: staff_portal
      password: staff_portal

#### Authentication setup

Staff Portal uses [Aker-Rails][] and [Aker][] for authentication.

[Aker-Rails]: https://github.com/NUBIC/aker-rails/
[Aker]: http://rubydoc.info/github/NUBIC/aker/

First, create a file under `/etc/nubic/ncs` for the the central
authentication parameters. These parameters will be used for all NCS
Navigator applications on the same server.

* In staging, the file name should be `aker-staging.yml`
* In production, the file name should be `aker-prod.yml`
* In development, the file name should be `aker-local.yml`

Contents:

    cas:
      base_url: https://cas.myinst.edu/

Second, define a bootstrap user in
`/etc/nubic/ncs/navigator.ini`. (See next section.)

#### Center-specific setup

Staff Portal uses [ncs_navigator_configuration][] for shared
configuration of the NCS Navigator suite applications. Most
configuration properties are documented in its [sample
configuration][ncsn_conf_sample]. Staff Portal looks for the
configuration in its default location, `/etc/nubic/ncs/navigator.ini`.

[ncs_navigator_configuration]: https://github.com/NUBIC/ncs_navigator_configuration
[ncsn_conf_sample]: http://rubydoc.info/gems/ncs_navigator_configuration/file/sample_configuration.ini

To further customize Staff Portal for your center, add one or more of
the following configuration elements to the `[Staff Portal]` section of
the configuration file. `bootstrap_user` is mandatory; all others are
optional.

    # The initial user for Staff Portal. This user will automatically
    # granted the User Administrator role and will thus be able to
    # provision more users. The username must be one that can be
    # authenticated with the CAS server that Staff Portal uses.
    bootstrap_user = jrp

    # for any futher development, developer's email address for development testing email
    development_email = "user@example.com"

    # Comma separated list of username for excluding users from weekly email reminder users list
    reminder_excluded_users = "jane,warren"

    # Google Analytics account number to analyze staff portal's traffic data
    google_analytics_number = "UA-1234"

### Development

You'll need to load the database structure into your local database server
on your development workstation before you can run the application.
This can be done by running:
 $ rake db:create
 $ rake db:migrate

### Deployment

Staff Portal is deployed with [capistrano][cap] from a workstation. On
the workstation, you need to create a configuration file
`/etc/nubic/db/ncs_deploy.yml` to describe where it should be
deployed to.

[cap]: https://github.com/capistrano/capistrano/wiki/

Example:

    ncs_staff_portal:
      # Repository for staff portal. This will always be this value
      # unless you wish to deploy your own fork.
      repo: "git://github.com/NUBIC/ncs_staff_portal.git"
      # path on the server where application will be deployed
      deploy_to: "/www/apps/ncs_staff_portal"
      # staging server hostname
      staging_app_server: "staging.server"
      # production server hostname
      production_app_server: "production.server"

After you check out the code, run `bundle install` to install the gems
you'll need. The first time you deploy, capistrano needs to set up the
directory layout it expects:

    $ bundle exec cap production deploy:setup

Then deploy to the configured server:

    $ bundle exec cap production deploy:migrations

(This deploys to your production server; to deploy to staging instead,
substitute "staging" for "production".)

After the first deployment, you should only need to run
`deploy:migrations` to get new versions. You can also use
`deploy:pending` to see what would be deployed.

If you have problems deploying, you can run this:

    $ bundle exec cap production deploy:check

and capistrano will try to tell you why it cannot deploy.

#### Deployment user

As currently configured, Staff Portal will be deployed as the user you
use to connect to the application server. The target directory must be
writable by that user, and (by way of Passenger) the software will be
executed with that users' permissions.

Most likely, the use account you use to connect to the application
server will be your personal account. We [may add specific
support][1622] for deploying using a different account from the login
account, but an option for now is to use an alias defined in
`.ssh/config` on the workstation. See issue [1622][] for a more
detailed discussion of this option.

[1622]: https://code.bioinformatics.northwestern.edu/issues/issues/show/1622

### Initialization

Staff Portal relies on many lists of data. It ships with [rake][]
tasks which will populate these lists from outside sources, usually
CSV files.

All the tasks should be executed from the application root on the
server where the application is deployed. Each one will need to be run
at least once for each environment in which Staff Portal is deployed.

[rake]: http://rake.rubyforge.org/

#### Code lists

Initialize the code lists from the MDES using [ncs_mdes][]:

    $ bundle exec rake mdes:load_codes_from_schema_20

[ncs_mdes]: https://github.com/NUBIC/ncs_mdes

#### Staff

Load all users as empty staff records:

    $ bundle exec rake users:load_to_portal

This creates staff records for the users specified in
`/etc/nubic/ncs/staff_portal_users.yml`. A sample file is included in this repository as [example_staff_portal_users][]

[example_staff_portal_users]:[https://github.com/umn-enhs/ncs_staff_portal/blob/master/example_staff_portal_users.yml]

#### Secondary sampling units

Load SSUs:

    $ bundle exec rake psu:load_ncs_area_ssus

This creates SSU and area records that reflect in the provided
CSV from the [ncs_navigator_configuration][] file which describes the sampling units for the study center.

#### Giveaway items

Load giveaway items:

    $ bundle exec rake giveaway_items:load_all[/path/to/giveaways.csv]

This will load all the giveaway items for the outreach activities in
the Staff Portal. The file must be a single column CSV file with all
items listed in the column `NAME`.
