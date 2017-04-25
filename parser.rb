require 'pdf-reader'
require 'date'
# Parses Tracklist and outputs a hash of track details
# example:
#    TracklistParser.new('Show #286.pdf').parse
#
class TracklistParser
  attr_accessor :source, :episode
  def initialize(source)
    @source = source
  end

  def parse_line(line, episode)
    parse_show_meta(line, episode)
    parse_tracks(line, episode)
    parse_sessions(line, episode)
  end

  def parse_show_meta(line, episode)
    line.scan(/^Show\s+#(\d+)/) do |matches|
      episode[:number] = matches[0].to_i
    end
    line.scan(/^Show\s+#(\d+).*(?:-|\|)\s+(\d{1,2}\s\w+\s\d{4})/) do |matches|
      episode[:date] = Date.parse(matches[1])
    end
  end

  def parse_tracks(line, episode)
    track = {}
    line.scan(/^\s*(\d+)\.\s*/) do |matches|
      track[:number] = matches[0].to_i
      track[:artist] = nil
      track[:title] = nil
      track[:session] = episode[:sessions].last
    end
    line.scan(/^\s*(\d+)\.\s*(.*)\s?[\–|\-](?:\s(.*))?/) do |matches|
      track[:number] = matches[0].to_i
      track[:artist] = matches[1]
      track[:title] = matches[2]
      track[:session] = episode[:sessions].last
    end
    episode[:tracks] << track if track.key?(:number)
    if episode[:number] == 304 && track.fetch(:number, nil) == 41
      episode[:tracks] << {
        number: 40,
        artist: nil,
        title: nil,
        session: episode[:sessions].last
      }
    end
    if track.key?(:number)
      if track[:number] != episode[:tracks].length && (episode[:number] != 261 && episode[:tracks].length > 3)
        raise StandardError, "Show ##{episode[:number]}: missing track from here #{track} #{episode[:tracks].length}"
      end
    end
  end

  def parse_sessions(line, episode)
    line.scan(/^((?!Show|\d).*(?:conversation|session|interview|set).*)\s+\(/i) do |matches|
      episode[:sessions] << matches[0]
    end
  end

  def parse
    reader = PDF::Reader.new(@source)
    lines = []
    reader.pages.each do |page|
      lines.concat(page.text.gsub(/\t/,' ').gsub(/\r/,'').gsub(/[-­|‐|–]+/,'-').split("\n"))
    end
    episode = { tracks: [], sessions: [], number: nil, date: nil }

    lines.each do |line|
      line = line.gsub(/[[:space:]]/, ' ').gsub(/\s+/,' ').strip
      parse_line(line, episode)
    end
    @episode = episode
  end
end
