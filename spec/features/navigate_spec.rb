require 'spec_helper'

describe Navigate, integration: true do
  let(:ori_uri){ 'https://www.digitalocean.com/' }
  let(:uri){ 'https://www.digitalocean.com/' }
  subject{ Navigate.new(ori_uri,uri) }

  it { expect(subject.class.respond_to?(:perform)).to eq(true) }

  context 'mixin' do
    it { expect(subject.respond_to?(:javascript)).to eq(true) }
    it { expect(subject.respond_to?(:stylesheets)).to eq(true) }
    it { expect(subject.respond_to?(:page)).to eq(true) }
  end

  context 'ori_uri' do
    it { expect(subject.ori_uri).to eq(ori_uri) }
  end

  context 'invalid uri' do
    it 'should raise an error when getting page contents fails' do
      expect{ Navigate.new(ori_uri,'http') }.to raise_error('Invalid URI')
    end
  end

  context 'perform' do
    it 'should construct an object representing the current search' do
      expect(subject.perform).to be_an_instance_of(OpenStruct)
    end

    it 'should persist the current_uri' do
      expect(subject.perform.uri).to eq(URI.parse(uri).path)
    end

    it 'should persist the assets' do
      expect(subject.perform.assets).to be_an_instance_of(Array)
    end

    it 'should persist the links within the page' do
      expect(subject.perform.links).to be_an_instance_of(Array)
    end
  end
end
