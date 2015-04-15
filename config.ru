require_relative 'rob'
Dir['app/controllers/*.rb'].each { |path| require File.join(File.dirname(__FILE__), path) }
Dir['config/*.rb'].each { |path| require File.join(File.dirname(__FILE__), path) }

run BroApp


