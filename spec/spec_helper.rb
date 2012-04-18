require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'

  # Prevent Devise from loading models super early with its route hacks.
  # https://github.com/timcharper/spork/wiki/Spork.trap_method-Jujutsu
  require "rails/application"
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'turnip/capybara'
  require 'draper/rspec_integration'

  RSpec.configure do |config|
    config.mock_with :rspec

    config.include FactoryGirl::Syntax::Methods
    config.include Devise::TestHelpers, :type => :controller

    config.run_all_when_everything_filtered = true

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, comment the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Clean up generated Dragonfly images after each run.
    config.after(:suite) do
      test_dragonfly_images = "#{Rails.root}/public/system/dragonfly/test"
      FileUtils.rm_r(test_dragonfly_images) if File.exists?(test_dragonfly_images)
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # Require test helper modules.
  RSpec.configure do |config|
    config.include Swidjit::TestHelpers::ImagePaths
  end

  require "#{Rails.root}/config/routes"
end

