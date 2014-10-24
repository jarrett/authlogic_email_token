require 'bundler'
Bundler.setup
require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'timecop'
require 'mocha/mini_test'
require 'database_cleaner'
require 'rails'
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))
require 'authlogic_email_token'
require 'authlogic/acts_as_authentic/email_token/railtie'

# This causes our module to be included in ActiveRecord::Base. That's all we need to do
# in order to activate our Authlogic plugin. In a real Rails app, this would be
# called automatically.
Authlogic::ActsAsAuthentic::EmailToken::Railtie.instance.run_initializers

require 'models'

DatabaseCleaner.strategy = :truncation

class Minitest::Test
  def setup
    DatabaseCleaner.clean
  end
end