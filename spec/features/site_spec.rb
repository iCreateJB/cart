require 'spec_helper'

describe Site do
  let(:ori_uri){ 'https://www.digitalocean.com/' }
  let(:uri){ 'https://www.digitalocean.com/' }
  subject{ Site.new(uri) }

  it { expect(subject.respond_to?(:crawl)).to eq(true) }

  context '.run' do
    it 'should return the page attributes (assets,links)' do
      crawl    = double('crawl')
      navigate = double('Navigate', links: [])
      expect(Navigate).to receive(:perform).with(ori_uri,uri).and_return(navigate)
      expect(subject.crawl(uri)).to be_an_instance_of(Hash)
    end

    it 'should call .crawl (1)' do
      crawl    = double('crawl')
      navigate = double('Navigate')
      expect(Navigate).to receive(:perform).once.with(ori_uri,uri).and_return(OpenStruct.new(assets: [], links: [], uri: uri))
      subject.crawl(uri)
    end

    it 'should call .crawl (n)' do
      crawl    = double('crawl')
      navigate = double('Navigate')
      links    = ['https://www.digitalocean.com/pricing','https://www.digitalocean.com/features','https://www.digitalocean.com/community']
      expect(Navigate).to receive(:perform).once.with(ori_uri,uri).and_return(OpenStruct.new(assets: [], links: links, uri: uri))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/pricing').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/pricing'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/features').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/features'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/community').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/community'))
      subject.crawl(uri)
    end

    it 'should limit not limit the depth' do
      crawl    = double('crawl')
      navigate = double('Navigate')
      links    = ['https://www.digitalocean.com/company','https://www.digitalocean.com/features','https://www.digitalocean.com/community']
      secLinks = ['https://www.digitalocean.com/company/contact']
      thirdLink= ['https://www.digitalocean.com/company/contact/thanks']
      expect(Navigate).to receive(:perform).once.with(ori_uri,uri).and_return(OpenStruct.new(assets: [], links: links, uri: uri))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/company').and_return(OpenStruct.new(assets: [], links: secLinks, uri: 'https://www.digitalocean.com/company'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/company/contact').and_return(OpenStruct.new(assets: [], links: thirdLink, uri: 'https://www.digitalocean.com/company/contact'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/company/contact/thanks').and_return(OpenStruct.new(assets: [], links: [], uri: uri))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/features').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/features'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/community').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/community'))
      subject.crawl(uri)
    end

    it 'should persist the keys' do
      crawl    = double('crawl')
      navigate = double('Navigate')
      links    = ['https://www.digitalocean.com/pricing','https://www.digitalocean.com/features','https://www.digitalocean.com/community']
      expect(Navigate).to receive(:perform).once.with(ori_uri,uri).and_return(OpenStruct.new(assets: [], links: links, uri: uri))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/pricing').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/pricing'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/features').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/features'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/community').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/community'))
      expect(subject.crawl(uri).keys).to eq([ori_uri].concat(links))
    end
  end

  context '.draw' do
    before(:each) do
      crawl    = double('crawl')
      navigate = double('Navigate')
      links    = ['https://www.digitalocean.com/pricing','https://www.digitalocean.com/features','https://www.digitalocean.com/community']
      expect(Navigate).to receive(:perform).once.with(ori_uri,uri).and_return(OpenStruct.new(assets: [], links: links, uri: uri))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/pricing').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/pricing'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/features').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/features'))
      expect(Navigate).to receive(:perform).once.with(ori_uri,'https://www.digitalocean.com/community').and_return(OpenStruct.new(assets: [], links: [], uri: 'https://www.digitalocean.com/community'))
      subject.crawl(uri)
    end

    it 'should return a String' do
      expect(subject.draw).to be_an_instance_of(String)
    end

    it 'should return the site map in the form of a yaml file.' do
      expect(!!YAML.load(subject.draw)).to eq(true)
    end
  end
end
