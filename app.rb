require 'rack'
require 'flickraw'
require 'pit'

$config = Pit.get('gyazo_to_flickr', :require => {
  'key'    => 'your app key',
  'secret' => 'your app secret',
  'token'  => 'your token'
})

class Upload
  def call(env)
    req = Rack::Request.new(env)
    params = req.params()

    res = Rack::Response.new

    id = params['id']

    imagedata = params["imagedata"][:tempfile].read

    hash = rand(256**16).to_s(16)

    write_path = "public/gyazo/#{hash}.png"
    File.open(write_path, 'w'){|f| f.write imagedata}

    url = flickr_upload write_path

    File.delete write_path

    res.write url
    res.finish
  end

  private
  def flickr_upload(file_path)
    FlickRaw.api_key = $config['key']
    FlickRaw.shared_secret = $config['secret']

    flickr.auth.checkToken :auth_token => $config['token']
    flickr.test.login

    photo_id = flickr.upload_photo(file_path, :title => 'Title', :description => 'This is the description').to_s

    info = flickr.photos.getInfo :photo_id => photo_id 
    info.urls[0]
  end
end

