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
      track.description.scan(/(?:Show #(\d+)).*track\s?list:\s(.+)/i) do |matches|
        show_number = matches[0]
        puts "Downloading ##{show_number}" unless already_downloaded?(show_number)
        next if already_downloaded?(show_number)
        raw = matches[1].strip
        raw = "http://#{raw}" unless raw.start_with?('http')
        uri = URI.parse(raw)
        dropbox_uri = follow_redirect(uri)
        dropbox_download_link = dropbox_download_link(dropbox_uri)
        download_from_dropbox(dropbox_download_link, show_number)
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

  def filename(show)
    File.join('./downloads', "Show ##{show}.pdf")
  end

  def download_from_dropbox(uri, show)
    File.write(filename(show), open(uri).read, {mode: 'wb'})
  end

  def already_downloaded?(show_number)
    File.exists?(filename(show_number))
  end
end
