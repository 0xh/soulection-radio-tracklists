# encoding: utf-8
require 'json'
require 'down'
require 'benchmark'

start = Time.now

BEATS_RADIO_BASE_URI = 'http://itsliveradio.apple.com/streams/hub01/session02/64k/'
BEATS_RADIO_FILE_NAME = 'prog.m3u8'

PROGRAMS_URI = 'http://fuse-music.herokuapp.com/api/programs'

TIME_DIFF = ((60*60)*14)

show = {}
soulection_shows = Array.new()
programs_data = Down.open(PROGRAMS_URI).read
json = JSON.parse(programs_data).fetch('programs')
json.each do |item|
  now = Time.now.utc.to_i
  start_at = item.fetch('start') / 1000
  finish_at = item.fetch('end') / 1000
  if now >= start_at && now < finish_at
    show = item
  end
  if item['title'] == 'Soulection' && finish_at >= now
    soulection_shows.push(item)
  end
end


sorted_shows = soulection_shows.sort do |a, b|
  a.fetch('start') <=> b.fetch('start')
end

soulection_show = sorted_shows.first

def from_epoch(time)
  Time.at(time / 1000)
end

if show['title'] != 'Soulection'
  due_at = (soulection_show['start'] /1000) - Time.now.utc.to_i
  puts "Soulection not on air - on air in #{Time.at(due_at - (60*60*24)).strftime("%jd %Hh %Mm %Ss")} (#{from_epoch(soulection_show['start']).strftime("%A, %d %b %Y %H:%M %p")})"
end

playlist = Down.open("#{BEATS_RADIO_BASE_URI}#{BEATS_RADIO_FILE_NAME}").read
filename = playlist.lines[-1].gsub(/\n/,'')
music_file = "#{BEATS_RADIO_BASE_URI}#{filename}"

file = Down.open(music_file, rewindable: false)
data = file.read(1024*4).split('\\').first
file.close
cleaned_data = data.gsub(/[^[:print:]]/,'')
data = /artworkURL_640x(.+)PRIV.*TALB(.*)TPE1(.*)TIT2(.*)/m.match(cleaned_data)
# puts cleaned_data

unless data
  puts 'Track has no data'
  exit
end

track = {
  artwork: data[1],
  album: data[2],
  artist: data[3],
  title: data[4]
}

program = { show: show, track: track }

filename = "./beats-radio/show-#{show['id']}.json"
if File.exists?(filename)
  file = File.read(filename)
else
  show['tracks'] = []
  file = JSON.pretty_generate(show)
end

json = JSON.parse(file)
unless json['tracks'].include?(JSON.parse(JSON.generate(track)))
  # json['played_at'] = Time.now
  json['tracks'] << track
end
json['last_updated_at'] = Time.now
File.write(filename, JSON.pretty_generate(json))

puts JSON.pretty_generate(program)
