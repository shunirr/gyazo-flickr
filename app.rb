require 'rack'
require 'flickraw'
require 'pit'

API_KEY='c5ec21924fb006939eb960ff444be1bc'
SHARED_SECRET='5a1ea4c1841ae7e6'

$config = Pit.get('gyazo_to_flickr', :require => {
  'token' => 'your token'
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
    puts url
    res.write url
    res.finish
  end

  private
  def flickr_upload(file_path)
    FlickRaw.api_key = API_KEY
    FlickRaw.shared_secret = SHARED_SECRET

    flickr.auth.checkToken :auth_token => $config['token']
    flickr.test.login

    photo_id = flickr.upload_photo(file_path, :title => 'Title', :description => 'This is the description').to_s

    info = flickr.photos.getInfo :photo_id => photo_id 
    info.urls[0]
  end
end

