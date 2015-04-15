Dir['config/*.rb'].each do |path|
  require File.join(File.dirname(__FILE__), path)
end

run BroApp


