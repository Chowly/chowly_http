# frozen_string_literal: true

describe ChowlyRestClient do
  describe '#get' do
    it 'calls execute' do
      expect(described_class).to receive(:execute).with(:get, 'https://www.google.com', any_args)
      described_class.get('https://www.google.com')
    end
  end

  describe '#put' do
    it 'calls execute' do
      expect(described_class).to receive(:execute).with(:put, 'https://www.google.com', '{}', any_args)
      described_class.put('https://www.google.com', '{}')
    end
  end

  describe '#patch' do
    it 'calls execute' do
      expect(described_class).to receive(:execute).with(:patch, 'https://www.google.com', '{}', any_args)
      described_class.patch('https://www.google.com', '{}')
    end
  end

  describe '#post' do
    it 'calls execute' do
      expect(described_class).to receive(:execute).with(:post, 'https://www.google.com', '{}', any_args)
      described_class.post('https://www.google.com', '{}')
    end
  end

  describe '#delete' do
    it 'calls execute' do
      expect(described_class).to receive(:execute).with(:delete, 'https://www.google.com', any_args)
      described_class.delete('https://www.google.com')
    end
  end

  describe '#head' do
    it 'calls execute' do
      expect(described_class).to receive(:execute).with(:head, 'https://www.google.com', any_args)
      described_class.head('https://www.google.com')
    end
  end

  describe '#options' do
    it 'calls execute' do
      expect(described_class).to receive(:execute).with(:options, 'https://www.google.com', any_args)
      described_class.options('https://www.google.com')
    end
  end

  describe '#logger' do
    context 'Rails is not defined' do
      let(:my_logger) { Object.new }

      before do
        allow(Logger).to receive(:new) { my_logger }
      end

      it 'returns a new logger' do
        expect(described_class.logger).to eq(my_logger)
      end
    end

    context 'Rails is defined' do
      before do
        object_double('Rails', logger: Logger.new(STDOUT)).as_stubbed_const
      end

      it 'returns a logger' do
        expect(described_class.logger).to eq(Rails.logger)
      end
    end
  end

  describe '#execute' do
    let(:chowly_http) { instance_double('ChowlyHttp::Client') }
    let(:chowly_http_class) { class_double('ChowlyHttp::Client').as_stubbed_const(transfer_nested_constants: true) }

    before do
      allow(chowly_http_class).to receive(:new) { chowly_http }
    end

    it 'calls a ChowlyHttp Client' do
      expect(chowly_http).to receive(:request)
      described_class.get('https://www.google.com')
    end

    it 'raises ChowlyRestClient errors' do
      exception = ChowlyHttp::NotFound.new
      exception.response = { body: '', status: 404 }
      allow(chowly_http).to receive(:request).and_raise(exception)
      expect { described_class.get('https://www.google.com') }.to raise_error(ChowlyRestClient::NotFound)
    end
  end

  describe '#get_cookies' do
    let(:cookie_jar) { HTTP::CookieJar.new }
    let(:cookie) { HTTP::Cookie.new(name, value, domain: 'example.org', for_domain: true, expired: expired, path: '/') }
    let(:name) { 'uid' }
    let(:value) { 'a12345' }
    let(:expired) { Time.now + 7 * 86_400 }
    let(:url) { 'http://example.org' }

    before do
      cookie_jar.add cookie
    end

    it 'returns a Hash of cookie name => value pairs' do
      expect(described_class.get_cookies(cookie_jar, url)).to eq(name => value)
    end
  end
end
