require "#{File.dirname(__FILE__)}/app.rb"

use Rack::ShowExceptions

use Rack::Static, :urls => ["/data"]

map '/upload' do
  run Upload.new
end

