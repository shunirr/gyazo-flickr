# coding: UTF-8

begin
require 'rubygems'
ensure
require 'rack'
require 'pit'
end

$LOAD_PATH << (RUBY_VERSION > '1.9' ? './lib' : 'lib')
require 'myflickraw'

$config = Pit.get('gyazo_to_flickr', :require => {
  'key'    => 'your app key',
  'secret' => 'your app secret',
  'token'  => 'your token'
})

class Upload
  def call(env)
    req = Rack::Request.new(env)
    params = req.params()


    imagedata = params["imagedata"][:tempfile].read
    url = flickr_upload imagedata

    res = Rack::Response.new
    res.write url
    res.finish
  end

  private
  def flickr_upload(data)
    FlickRaw.api_key = $config['key']
    FlickRaw.shared_secret = $config['secret']

    flickr.auth.checkToken :auth_token => $config['token']
    flickr.test.login

    photo_id = flickr.upload_photo_raw(data, :title => 'Title', :description => 'This is the description').to_s

    info = flickr.photos.getInfo :photo_id => photo_id 
    info.urls[0]
  end
end

