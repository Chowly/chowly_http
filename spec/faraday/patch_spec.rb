# frozen_string_literal: true

describe Faraday::Adapter::Typhoeus do
  subject { described_class.new({}) }

  describe '#configure_proxy' do
    let(:env) { OpenStruct.new(proxy_headers: { test: 'ok' }, request: { proxy: { user: 'u', password: 'p', uri: URI('http://u:p@l.com:80') } }) }
    let(:req) { OpenStruct.new(options: {}) }

    before do
      subject.configure_proxy(req, env)
    end

    it 'adds a callback', :aggregate_failures do
      expect(req).to receive(:on_headers) do |&block|
        expect(block).to be_a(Proc)
      end
      subject.configure_proxy(req, env)
    end

    it 'sets options proxy' do
      expect(req.options[:proxy]).to eq('http://l.com:80')
    end

    it 'sets options proxyauth' do
      expect(req.options[:proxyauth]).to eq(:basic)
    end

    it 'sets options proxyuserpwd' do
      expect(req.options[:proxyuserpwd]).to eq('u:p')
    end

    it 'sets options proxyheader' do
      expect(req.options[:proxyheader]).to eq(test: 'ok')
    end
  end

  describe '#parse_proxy_headers' do
    let(:raw) do
      File.read(File.expand_path('../data/http.txt', __dir__)).split("\n").join("\r\n")
    end

    let(:headers) { subject.parse_proxy_headers(raw) }

    it 'parsed the proxy headers' do
      expect(headers).to eq(
        'This-is-a-proxy-header' => 'Neat',
        'This-is-also-a-proxyheader' => 'Cool'
      )
    end
  end
end
