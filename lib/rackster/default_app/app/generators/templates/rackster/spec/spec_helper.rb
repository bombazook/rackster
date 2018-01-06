require "bundler/setup"
require 'securerandom'
require 'fileutils'
require 'byebug'
require 'factory_girl'
require 'database_cleaner'

ENV['RACKSTER_ENV'] = 'test'
Dir[File.join(__dir__, 'shared/**/*.rb')].each{|i| require i}
Dir[File.join(__dir__, "factories/**/*.rb")].each {|f| require f}


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.expose_dsl_globally = false

  @default_app_id = SecureRandom.hex(10)

  config.before :all do
    generate_app @default_app_id
  end

  DatabaseCleaner.strategy = :truncation

  config.before :each do
    Faker::Config.random = Random.new(config.seed)
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.on_potential_false_positives = :raise
  end

  config.order = "random"
  config.include FactoryGirl::Syntax::Methods

end
