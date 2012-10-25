NCS Navigator Ops
==========================

NCS Navigator Ops keeps track of the staff information including
demographic information, time, hours, expenses. It also keeps track of
all the outreach activities for the study center. NCS Navigator Ops's data
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

NCS Navigator Ops uses [bcdatabase][] to discover the database
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
      port: 5432
    ncs_staff_portal:
      database: staff_portal_staging   # database name
      username: staff_portal
      password: staff_portal

#### Authentication setup

NCS Navigator Ops uses [Aker-Rails][] and [Aker][] for authentication.

[Aker-Rails]: https://github.com/NUBIC/aker-rails/
[Aker]: http://rubydoc.info/github/NUBIC/aker/

First, create a file under `/etc/nubic/ncs` for the the central
authentication parameters. These parameters will be used for all NCS
Navigator applications on the same server.

* In staging, the file name should be `aker-staging.yml`
* In production, the file name should be `aker-prod.yml`

Contents:

    cas:
      base_url: https://cas.myinst.edu/

Second, define a bootstrap user in
`/etc/nubic/ncs/navigator.ini`. (See next section.)

#### Center-specific setup

NCS Navigator Ops uses [ncs_navigator_configuration][] for shared
configuration of the NCS Navigator suite applications. Most
configuration properties are documented in its [sample
configuration][ncsn_conf_sample]. NCS Navigator Ops looks for the
configuration in its default location, `/etc/nubic/ncs/navigator.ini`.

[ncs_navigator_configuration]: https://github.com/NUBIC/ncs_navigator_configuration
[ncsn_conf_sample]: http://rubydoc.info/gems/ncs_navigator_configuration/file/sample_configuration.ini

To further customize NCS Navigator Ops for your center, add one or more of
the following configuration elements to the `[Staff Portal]` section of
the configuration file. `bootstrap_user` and `psc_user_password` are mandatory; 
all others are optional.

    # The initial user for NCS Navigator Ops. This user will automatically
    # granted the User Administrator and System Administrator roles. Thus he will be able to
    # provision more users and finish the initial PSC setup for NCS Navigator. The username 
    # must be one that can be authenticated with the CAS server that NCS Navigator Ops uses.
    bootstrap_user = jrp
    
    # The psc user password for NCS Navigator Ops. There will be application 
    # user with username as "psc_application" which will be used for 
    # communication between Patient Study Calendar and NCS Navigator Ops.
    psc_user_password = "password"

    # for any futher development, developer's email address for development testing email
    development_email = "user@example.com"
    
    # weekly email reminder can be enable or disable for the particular deployment.
    email_reminder = false

    # Google Analytics account number to analyze NCS Navigator Ops's traffic data
    google_analytics_number = "UA-1234"

### Deployment

NCS Navigator Ops is deployed with [capistrano][cap] from a workstation. On
the workstation, you need to create a configuration file
`/etc/nubic/db/ncs_deploy.yml` to describe where it should be
deployed to.

For multiple SC deployment, you can create file for each study center and pass the file with the environment variable `STUDY_CENTER`.

e.g `STUDY_CENTER=umn cap production deploy`. 

This will read the configuration parameters from the 'umn_deploy.yml' file. By default file will be always `ncs_deploy.yml`


[cap]: https://github.com/capistrano/capistrano/wiki/

Example:

    ncs_staff_portal:
      # Repository for NCS Navigator Ops. This will always be this value
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

if you make changes to the footer logo paths in navigator.ini in between deploys, you have to run rake task to copy images
    
    $ bundle exec cap production config:images
    
you can seed the data to the database (MDES codes, Roles creation) with following command

    $ bundle exec cap production db:seed

#### Deployment user

As currently configured, NCS Navigator Ops will be deployed as the user you
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

NCS Navigator Ops relies on many lists of data. It ships with [rake][]
tasks which will populate these lists from outside sources, usually
CSV files.

All the tasks should be executed from the application root on the
server where the application is deployed. Each one will need to be run
at least once for each environment in which NCS Navigator Ops is deployed.

RAILS_ENV needs to be set to the appropriate value (production, staging) when running the various setup rake tasks for production or staging environment.
e.g `bundle exec rake mdes:load_codes_from_schema_20 RAILS_ENV=production`

[rake]: http://rake.rubyforge.org/

#### Code lists

Initialize the code lists from the MDES using [ncs_mdes][]:

    $ bundle exec rake mdes:load_codes_from_schema_20

[ncs_mdes]: https://github.com/NUBIC/ncs_mdes

#### Secondary sampling units

Load SSUs with Areas:

    $ bundle exec rake psu:load_ncs_area_ssus

This creates SSU and area records that reflect in the provided CSV from the [ncs_navigator_configuration][] file which describes the sampling units for the study center.

Load SSUs:

    $ bundle exec rake psu:load_ncs_ssus
    
This creates SSU records that reflect in the provided CSV from the [ncs_navigator_configuration][] file which describes the sampling units for the study center.

#### Giveaway items

Load giveaway items:

    $ bundle exec rake giveaway_items:load_all[/path/to/giveaways.csv]

This will load all the giveaway items for the outreach activities in
the NCS Navigator Ops. The file must be a single column CSV file with all
items listed in the column `NAME`. This is not the mandatory task though because MDES doesn't require any giveaway items data and it is not being submitted to VDR.

#### Load users

Load new users or map existing users with staff_id:

    $ bundle exec rake users:load[/path/to/users.csv]
    
The CSV must have the following header (along with the contents it implies):
`USERNAME`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `STAFF_ID`

If `STAFF_ID` is specify then staff record with particular `STAFF_ID` will be updated for attributes like `username`, `first_name`, `last_name` and `email`.

If `STAFF_ID` is not specify for some rows, NCS Navigator Ops will consider those entries as new staff records and will create new entries in the NCS Navigator Ops.
