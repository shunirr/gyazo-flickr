# coding: UTF-8

begin
  require 'rubygems'
ensure
  require 'sinatra'
  require 'pit'
  require 'sdbm'
  require 'haml'
  require 'digest/sha1'
  require 'yaml'
end

$LOAD_PATH << (RUBY_VERSION > '1.9' ? './lib' : 'lib')
require 'myflickraw'

CONFIG_FILE = 'config.yaml'
$config = YAML.load_file CONFIG_FILE

def flickr_upload(token, data)
  FlickRaw.api_key = $config['app']['key']
  FlickRaw.shared_secret = $config['app']['secret']

  flickr.auth.checkToken :auth_token => token
  flickr.test.login

  photo_id = flickr.upload_photo_raw(data, :title => '', :description => '').to_s

  info = flickr.photos.getInfo :photo_id => photo_id 
  info.urls[0].to_s
end

def auth_url
  FlickRaw.api_key = $config['app']['key']
  FlickRaw.shared_secret = $config['app']['secret']

  FlickRaw.auth_url(:frob => flickr.auth.getFrob, :perms => 'write').to_s
end

def get_token(frob)
  FlickRaw.api_key = $config['app']['key']
  FlickRaw.shared_secret = $config['app']['secret']

  auth = flickr.auth.getToken :frob => frob
  flickr.test.login
  auth.token.to_s
end

db = SDBM.open 'db/users'

get '/' do
  haml :index
end

get '/signup' do
  redirect auth_url
end

get '/complete' do
  @hash = params[:hash] 
  haml :complete
end

get '/callback' do
  begin
    token = get_token params[:frob] 
    hash = Digest::SHA1.hexdigest(token)
    db[hash] = token
    redirect "complete?hash=#{hash}"
  rescue => e
    status 500
    ''
  end
end

post %r{/([A-Za-z0-9]+)} do
  hash = params[:captures].first
  if db.key? hash
    begin
      imagedata = params["imagedata"][:tempfile].read
      flickr_upload db[hash], imagedata
    rescue => e
      status 500
      ''
    end
  else 
    status 403
    ''
  end
end

