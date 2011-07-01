require 'rubygems'
require 'flickraw'
require 'pit'

API_KEY = 'c5ec21924fb006939eb960ff444be1bc'
SECRET  = '5a1ea4c1841ae7e6'

FlickRaw.api_key = API_KEY
FlickRaw.shared_secret = SECRET

frob = flickr.auth.getFrob
auth_url = FlickRaw.auth_url :frob => frob, :perms => 'write'

puts "Open this url in your process to complete the authication process : #{auth_url}"
puts "Press Enter when you are finished."
STDIN.getc

begin
  auth = flickr.auth.getToken :frob => frob
  login = flickr.test.login
  puts "You are now authenticated as #{login.username} with token #{auth.token}"
  Pit.set('gyazo_to_flickr', :data => {'token' => auth.token})
rescue FlickRaw::FailedResponse => e
  puts "Authentication failed : #{e.msg}"
end

