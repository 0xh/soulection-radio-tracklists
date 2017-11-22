require './parser'
require './soulection'
require './render'
require 'json'

class ProcessFiles

  def initialize
  end

  def parse_all
    files = Dir["./downloads/*.pdf"]
    files.each do |file|
      parse(file)
    end
  end

  def parse(file)
    show_number = file.scan(/\d+/).first
    return if show_number < 320
    filename = File.join('data',"episode_#{show_number}.json")
    if File.exists?(filename)
      json = JSON.parse(File.read(filename))
    else
      json = {}
    end
    parser = TracklistParser.new(file)
    if show_number
      data =  parser.parse
      json['tracks'] = data[:tracks]
      json['sessions'] = data[:sessions]
      json['number'] = show_number.to_i
      json['date'] = data[:date]
      File.write(filename, JSON.pretty_generate(json), {mode: 'w'})
    end
  rescue => e
    puts "Failed to parse ##{show_number}"
    puts e.message
  end

end

SoulectionRadioPlaylist.new.download
ProcessFiles.new.parse_all
RenderHTML.new
