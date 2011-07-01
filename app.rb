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

module FlickRaw
  class Flickr
    def upload_photo_raw(data, args={}); upload_flickr_raw(UPLOAD_PATH, data, args) end

    private
    def upload_flickr_raw(method, photo, args={})
      boundary = Digest::MD5.hexdigest(photo)

      header = {'Content-type' => "multipart/form-data, boundary=#{boundary} ", 'User-Agent' => "Flickraw/#{VERSION}"}
      query = ''

      build_args(args).each { |a, v|
        query <<
          "--#{boundary}\r\n" <<
          "Content-Disposition: form-data; name=\"#{a}\"\r\n\r\n" <<
          "#{v}\r\n"
      }
      query <<
        "--#{boundary}\r\n" <<
        "Content-Disposition: form-data; name=\"photo\"; filename=\"gyazo.png\"\r\n" <<
        "Content-Transfer-Encoding: binary\r\n" <<
        "Content-Type: image/jpeg\r\n\r\n" <<
        photo <<
        "\r\n" <<
        "--#{boundary}--"

      http_response = open_flickr {|http| http.post(method, query, header) }
      xml = http_response.body
      if xml[/stat="(\w+)"/, 1] == 'fail'
        msg = xml[/msg="([^"]+)"/, 1]
        code = xml[/code="([^"]+)"/, 1]
        raise FailedResponse.new(msg, code, 'flickr.upload')
      end
      type = xml[/<(\w+)/, 1]
      h = {
        "secret" => xml[/secret="([^"]+)"/, 1],
        "originalsecret" => xml[/originalsecret="([^"]+)"/, 1],
        "_content" => xml[/>([^<]+)<\//, 1]
      }.delete_if {|k,v| v.nil? }
      Response.build(h, type)
    end
  end
end

