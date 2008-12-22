require File.dirname(__FILE__) + "/../init"
require "rubygems"
require "mocha"

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
