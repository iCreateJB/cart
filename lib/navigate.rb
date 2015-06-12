require_relative 'filter'
require 'open-uri'
require 'nokogiri'

class Navigate
  include Filter

  attr_accessor :ori_uri, :uri, :source

  class << self
    def perform(ori_uri,uri)
      self.new(ori_uri,uri).perform
    end
  end

  def initialize(ori_uri,uri)
    self.ori_uri  = ori_uri
    @uri          = uri
    @base_path    = URI.parse(uri).path
    begin
      @source       = Nokogiri::HTML(open(uri))
    rescue 
      raise 'Invalid URI'
    end
  end

  def perform
    OpenStruct.new(
      uri: @base_path,
      assets: javascript + stylesheets,
      links: page
    )
  end
end
