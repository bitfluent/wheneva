$TESTING=true
require 'rubygems'
require 'rack'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'warden'

Dir[File.join(File.dirname(__FILE__), "helpers", "**/*.rb")].each do |f|
  require f
end

Spec::Runner.configure do |config|
  config.include(Warden::Spec::Helpers)

  def load_strategies
    Dir[File.join(File.dirname(__FILE__), "warden", "strategies", "**/*.rb")].each do |f|
      load f
    end
  end
end
