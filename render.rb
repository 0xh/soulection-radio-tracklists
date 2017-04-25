require 'erb'
require 'json'
require 'uri'


class RenderHTML
  def initialize
    index_source = File.read(File.join('index.html.erb'))

    tracklist_source = File.read(File.join('track.html.erb'))
    collection = []
    Dir.glob('data/*.json') do |item|
      @previous_session = nil
      @json = JSON.parse(File.read(item))
      @search_params =  URI.escape("#{@json['artist']} - #{@json['title']}")
      collection << @json
      next unless @json.has_key? 'tracks'
      renderer = ERB.new(tracklist_source).result(binding)
      File.write(File.join('out', "episode_#{item.gsub(/\D/, '')}.html"), renderer, mode: 'w')
    end
    @collection = collection
    renderer = ERB.new(index_source).result(binding)
    File.write(File.join('out', "index.html"), renderer, mode: 'w')
  end
end
