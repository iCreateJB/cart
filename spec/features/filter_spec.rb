require './lib/filter'
require 'spec_helper'

describe Filter, integration: true do
  let(:ori_uri){ 'https://www.digitalocean.com/' }
  let(:uri){ 'https://www.digitalocean.com/' }
  subject{ TestNavigate.new(ori_uri,uri) }

  it { expect(subject.respond_to?(:javascript)).to eq(true) }
  it { expect(subject.respond_to?(:stylesheets)).to eq(true) }
  it { expect(subject.respond_to?(:page)).to eq(true) }

  context 'javascript' do
    it { expect(subject.javascript).to be_an_instance_of(Array) }

    it 'should include all javascript files' do
      expect(subject.javascript.size).to eq(subject.javascript.reject{|i| !i.match(/.js/) }.size)
    end
  end

  context 'stylesheets' do
    it { expect(subject.stylesheets).to be_an_instance_of(Array) }

    it 'should include all stylesheets (css) files' do
      expect(subject.stylesheets.size).to eq(subject.stylesheets.reject{|i| !i.match('(css|sass|less)') }.size)
    end
  end

  context 'page' do
    it { expect(subject.page).to be_an_instance_of(Array) }

    it 'should contain internal links ( first-post )' do
      resp = double('parse')
      expect(subject).to receive(:parse).and_return(['first-post','/second-post', 'http://example.com'])
      expect(subject.page.include?('first-post')).to eq(true)
    end

    it 'should not contain external links ( twitter )' do
      resp = double('parse')
      expect(subject).to receive(:parse).and_return(['first-post','/second-post', 'http://example.com', 'http://www.twitter.com'])
      expect(subject.page.include?('http://www.twitter.com')).to eq(false)
    end

    it 'should not contain subdomains ( beta.example.com )' do
      resp = double('parse')
      expect(subject).to receive(:parse).and_return(['first-post','/second-post', 'http://example.com', 'http://www.twitter.com', 'http://www.beta.example.com'])
      expect(subject.page.include?('http://www.beta.example.com')).to eq(false)
    end
  end
end

class TestNavigate
  include Filter

  attr_accessor :ori_uri, :uri, :source

  def initialize(ori_uri, uri)
    self.ori_uri= ori_uri
    self.uri    = uri
    self.source = Nokogiri::HTML(open(uri))
  end
end
