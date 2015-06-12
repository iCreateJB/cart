require_relative 'lib/navigate'
require_relative 'lib/plot'

require 'pry'
require 'yaml'

class Site
  attr_accessor :init_uri, :processed

  def initialize(uri)
    self.init_uri = uri
    self.processed= {}
  end

  def crawl(uri,depth=2)
    paths = uri.is_a?(Array) ? uri : [uri]
    paths.each do |i|
      resp           = Navigate.perform(init_uri,i)
      processed[i] = resp
      (resp.links.empty?) ? next : crawl(resp.links)
    end
    processed
  end

  def draw
    map = {}
    processed.map{|k,v| map[k] = { links: v.links, assets: v.assets } }
    map.to_yaml
  end
end
