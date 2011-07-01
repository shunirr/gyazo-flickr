require "rack"
require "flickraw"

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

    id = flickr_upload write_path
    res.write "#{URL_BASE}#{id}"
    res.finish
  end

  API_KEY='c5ec21924fb006939eb960ff444be1bc'
  SHARED_SECRET='5a1ea4c1841ae7e6'
  TOKEN = ' your token code '
  URL_BASE = 'http://www.flickr.com/photos/shunirr/'

  private
  def flickr_upload(file_path)
    FlickRaw.api_key = API_KEY
    FlickRaw.shared_secret = SHARED_SECRET

    flickr.auth.checkToken :auth_token => TOKEN
    flickr.test.login

    flickr.upload_photo(file_path, :title => 'Title', :description => 'This is the description').to_s
  end
end

