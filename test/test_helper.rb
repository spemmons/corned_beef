require 'rubygems'
require 'bundler/setup'
require 'simplecov'

SimpleCov.start'rails' do
  add_filter '/test/'
end

require 'test/unit'
begin; require 'turn'; rescue LoadError; end
require 'shoulda'

require 'active_record'
require 'corned_beef'

$:.unshift File.expand_path('../../lib', __FILE__)

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'rails'

class Application < Rails::Application; end

Application.configure do
  config.active_support.deprecation = :log
  config.root = File.dirname(__FILE__)
end

Application.initialize!
