module SoundcloudStreamer
  class CLI < ::Thor
    package_name "Soundcloud Streamer v#{SoundcloudStreamer::VERSION}"

    desc "playlist <URL>", "streams and saves all tracks from the playlist"
    method_options client_id: :string, target_dir: :string, overwrite: :boolean
    def playlist(url)
      response = playlist = client.get('/resolve', url: url, limit: 100)

      if response.kind == 'playlist'
        instant_print "Going to Stream all #{playlist.tracks.count} Tracks from Playlist ...\r\n"
      else
        puts "Isn't a playlist. It's a #{response.kind.inspect}"
        exit(-8)
      end

      track_num_justr = playlist.tracks.count.to_s.length
      playlist.tracks.each_with_index do |track, track_idx|
        track_num = track_idx + 1
        track_num_str = track_num.to_s.rjust(track_num_justr, '0')

        unless track.streamable?
          instant_print "Unstreamable-#{track_num}.\r\n"
          next
        end

        download_name = File.join(target_dir, [ track_num_str, ' ', track.title, '.mp3' ].join.gsub('/',' - ') )
        download_file = nil

        if File.exist?(download_name) && !overwrite?
          instant_print "Exisiting-#{track_num}.\r\n"
          next
        end

        uri = URI.parse(track.stream_url)
        uri.query = URI.encode_www_form(client_id: client_id)

        request = Typhoeus::Request.new(uri, followlocation: true)
        request.on_headers do |response|
          if response.code == 200
            instant_print "Streaming-#{track_num}."
            download_file = File.open(download_name, 'w+b')
          else
            raise "Request '#{uri.to_s}' failed"
          end
        end

        request.on_body do |chunk|
          download_file.write(chunk)
          instant_print "."
        end

        request.on_complete do |response|
          download_file.close

          artwork_data = nil
          artwork_url = track.artwork_url || playlist.artwork_url
          if artwork_url
            instant_print "Artwork."
            response = Typhoeus.get(artwork_url, followlocation: true)
            if response.code == 200
              artwork_data = response.body
            end
            instant_print "."
          end

          instant_print "Tagging."
          Mp3Info.open(download_file.path) do |mp3|
            mp3.tag.title = track.title.to_s.strip
            mp3.tag.artist = 'SoundCloud'
            mp3.tag.album = playlist.title.to_s.strip
            mp3.tag.year = $1 if track.created_at.to_s =~ /^(\d{4})/
            mp3.tag.tracknum = track_num
            mp3.tag.comments = [ "Streamed from SoundCloud", track.permalink_url ].join("\r\n")
            instant_print "."

            mp3.tag2.TCOP = track.license.to_s.strip
            mp3.tag2.TPUB = track.user.username.to_s.strip
            instant_print "."

            if artwork_data
              mime = File.extname(artwork_url) ? File.extname(artwork_url)[1..-1] : nil
              mp3.tag2.add_picture(artwork_data, pic_type: 0, mime: mime, description: "Artwork")
              instant_print "."
            end
          end

          instant_print "ok\r\n"
        end

        request.run
      end
    end

  private

    def config_paths
      [ Dir.home, Dir.getwd ].map { |directory| File.join(directory, '.soundcloud_streamer') }
    end

    def config
      @config ||= begin
        config = {}
        config_paths.each do |config_path|
          if File.file?(config_path) && File.readable?(config_path)
            config_part = YAML.load( File.read(config_path) )
            if config_part.is_a?(Hash)
              config.merge!(config_part)
            else
              raise "invalid configuration in '#{config_path}'"
            end
          end
        end
        config
      end
    end

    def client_id
      @client_id ||= begin
        options[:client_id] || config["client_id"]
      end
    end

    def client
      @client ||= begin
        raise "no client_id given" if client_id.nil? || client_id.empty?
        Soundcloud.new(client_id: client_id)
      end
    end

    def target_dir
      target_dir = options[:target_dir] || Dir.getwd
      unless File.exist?(target_dir)
        FileUtils.mkdir_p(target_dir)
      end
      target_dir
    end

    def overwrite?
      options[:overwrite] || false
    end

    def instant_print(*params)
      print(*params) { STDOUT.flush }
    end

  end
end