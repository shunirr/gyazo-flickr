require 'rubygems'
require 'flickraw'
require 'pit'

DEFAULT_APP_KEY    = 'c5ec21924fb006939eb960ff444be1bc'
DEFAULT_APP_SECRET = '5a1ea4c1841ae7e6'

config = {'app' => {}}

print "Input your APP Key: (Press enter, if use default APP Key): "
app_key = gets.chomp
if app_key == ''
  config['app']['key']    = DEFAULT_APP_KEY
  config['app']['secret'] = DEFAULT_APP_SECRET
else
  config['app']['key'] = app_key
end

unless config['app']['secret']
  print "Input your Application Secret: "
  config['app']['secret'] = gets.chomp
end

FlickRaw.api_key       = config['app']['key']
FlickRaw.shared_secret = config['app']['secret']

frob = flickr.auth.getFrob

puts "Open this url in your process to complete the authication process :"

auth_url = FlickRaw.auth_url :frob => frob, :perms => 'write'
puts "---"
puts auth_url
puts "---"
puts "Press Enter when you are finished."
STDIN.getc

begin
  auth = flickr.auth.getToken :frob => frob
  login = flickr.test.login

  Pit.set("gyazo_to_flickr", :data => {
    'key'    => config['app']['key'],
    'secret' => config['app']['secret'],
    'token'  => auth.token
  })

  puts "Complete Setup!!"
rescue FlickRaw::FailedResponse => e
  puts "Authentication failed : #{e.msg}"
end

