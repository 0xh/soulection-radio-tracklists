require 'soundcloud'
require 'uri'
require 'cgi'
require 'open-uri'
require 'net/http'
require 'open_uri_redirections'
YOUR_CLIENT_ID = 'y85IrsSgMLw3EYnSygC7pA'.freeze

class SoulectionRadioPlaylist
  attr_accessor :tracklist_links
  def initialize
    @tracklist_raw_links = []
    @tracklist_links = []
  end

  def download
    client = SoundCloud.new(client_id: YOUR_CLIENT_ID)
    playlist = client.get('/playlists/8025093')
    playlist.tracks.each do |track|
      track.description.scan(/(?:Show #(\d+)).*[tT]rack\s?[lL]ist:\s(.+)?/i) do |matches|
        show_number = matches[0]
        puts "Downloading ##{show_number}" unless already_downloaded?(show_number)
        if matches[1]
          raw = matches[1].strip
          raw = "http://#{raw}" unless raw.start_with?('http')
        else
          raw = "http://coming soon"
        end
        create_or_update_artwork(show_number, track, raw)

        next if already_downloaded?(show_number)

        begin
          uri = URI.parse(raw)
          dropbox_uri = follow_redirect(uri)
          dropbox_download_link = dropbox_download_link(dropbox_uri)
          download_from_dropbox(dropbox_download_link, show_number)
        rescue URI::InvalidURIError => e
          puts "Failed on #{show_number} - #{raw}"
        end
      end
    end
  end


  def follow_redirect(link)
    res = Net::HTTP.get_response(URI(link))
    res['location'].gsub(' ','+')
  end

  def dropbox_download_link(link)
    uri = URI.parse(link)
    uri.query = 'dl=1'
    uri.to_s
  end

  def create_or_update_artwork(show_number, track, tracklist_url)
    file = File.join('data',"episode_#{show_number}.json")
    if File.exists?(file)
      json = JSON.parse(File.read(file))
    else
      json = {}
    end
    json['date'] = nil unless json['date']
    json['tracks'] = [] unless json['tracks']
    json['number'] = show_number.to_i
    json['listen_url'] = track.permalink_url
    json['artwork_url'] = track.artwork_url.gsub('large', 't500x500')
    json['download_url'] = track.download_url
    json['waveform_url'] = track.waveform_url
    json['stream_url'] = track.stream_url
    json['tracklist_url'] = tracklist_url

    File.write(file, JSON.pretty_generate(json),{mode:'w'})
  end

  def filename(show)
    File.join('./downloads', "Show ##{show}.pdf")
  end

  def download_from_dropbox(uri, show)
    File.write(filename(show), open(uri).read, {mode: 'wb'})
  end

  def already_downloaded?(show_number)
    return false if show_number == 291
    File.exists?(filename(show_number))
  end
end
