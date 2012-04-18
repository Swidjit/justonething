namespace :swidjit do
  desc 'Set environment vars defined in the production group of config/secrets.yml on the specified Heroku app.'
  task :share_secrets, :heroku_app do |task, args|
    raise "This task requires the heroku gem and it could not be found." unless defined?(Heroku)
    raise "Which heroku app do you want to share secrets with? Format is rake swidjit:share_secrets[heroku_app]" unless args[:heroku_app].present?

    @heroku_app = args[:heroku_app]

    msg  = "This task will sync ALL ENVIRONMENT VARIABLES in the `#{@heroku_app}` app "
    msg += "with the values defined in the `production` group of config/secrets.yml. "
    msg += "Are you sure you want to proceed? (y/n)"
    puts msg

    confirmation = $stdin.gets.chomp
    raise unless confirmation == "y"

    dev_secrets = File.open("#{Rails.root}/config/secrets.yml")
    dev_yaml    = YAML.load(dev_secrets)

    config_string = ""
    dev_yaml.fetch('production').each do |key, value|
      config_string.concat("#{key}=#{value} ")
    end
    sh "heroku config:add #{config_string} --app #{@heroku_app}"
  end
end