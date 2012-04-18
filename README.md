## API Keys and other Secrets ##

### Storing Credentials ###

All sensitive credentials are stored in the `config/secrets.yml` file which is **not checked into source control**. See `config/secrets.yml.example` for the proper format. You may be able to get a copy of this file manually from another developer.

Keys and secrets in the `config/secrets.yml` file are converted into environment variables at runtime which can be accessed from your code.

For example, take following YAML file:

    development:
      SUPER_SECRET: "Jeremiah was a bullfrog."`
    production:
      SUPER_SECRET: "He was a good friend of mine."

In development:

    $ rails console -e development
      > ENV["SUPER_SECRET"]
      => "Jeremiah was a bullfrog."

In production:

    $ rails console -e production
      > ENV["SUPER_SECRET"]
      => "He was a good friend of mine."

### Copying the Database ###
PgBackups are installed (https://devcenter.heroku.com/articles/pgbackups), so to get a copy of the most recent database:
1. Initiate a backup if necessary
2. Get a list of the current backups using 
3. Create a url where you can grab the file using one of the backups (ie b001)
4. Grab the file using curl or your browser
5. Add db to local env

    heroku pgbackups:capture
    heroku pgbackups
    heroku pgbackups:url b001
    pg_restore --verbose --clean --no-acl --no-owner -h localhost     -U username -d swidjit_development b001.dump


### Deploying Secrets ###

Use `bundle exec rake swidjit:share_secrets[heroku_app]`, where `heroku_app` is the name of the app you want to deploy your secrets to.

This will deploy all the keys/values defined in the `production` group of your `config/secrets.yml` file as environment variables on Heroku.

## Testing Frameworks ##

swidjit uses the following testing frameworks:

* `rspec` for unit testing. (https://www.relishapp.com/rspec)
* `turnip` and `capybara` for acceptance testing. (https://github.com/jnicklas/turnip, https://github.com/jnicklas/capybara)
* `factory_girl` for fixture replacement. (https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md)

## Automated Testing ##
* Run `bundle exec guard` to start the automated testing server.
