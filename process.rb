require './parser'
require './soulection'
require 'json'

SoulectionRadioPlaylist.new.download

files = Dir["./downloads/*.pdf"]

files.each do |file|
  show_number = file.scan(/\d+/).first
  begin
    parser = TracklistParser.new(file)
    if show_number
      data = parser.parse
      File.write(File.join('./data',"episode_#{show_number}.json"), JSON.pretty_generate(data), {mode: 'w'})
    end
  rescue => e
    puts "Failed to parse ##{show_number}"
    puts e
  end
end
