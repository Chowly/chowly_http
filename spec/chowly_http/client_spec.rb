# frozen_string_literal: true

describe ChowlyHttp::Client do
  context 'tests ChowlyHttp client' do
    describe 'connection settings' do
      subject { described_class.new(verify_ssl: false) }

      let(:connection) { subject.send :get_connection, url: 'https://www.chowly.com' }

      it 'sets ssl verification false' do
        expect(connection.ssl.verify).to eq(false)
      end

      it 'sets parameter encoder to default' do
        expect(connection.options.params_encoder).to eq(ChowlyHttp::UnorderedEncoder)
      end
    end

    describe 'send function' do
      let!(:resp) { subject.send :get_connection, url: 'https://www.chowly.com' }

      it 'with correct type' do
        expect(resp).to be_a_kind_of Faraday::Connection
      end

      it 'with correct headers' do
        expect(resp.headers).to eq('User-Agent' => 'Chowly', 'X-App-Env' => 'the_chowly', 'X-App-Name' => 'Chowly')
      end
    end

    describe 'parsing url without a port' do
      let(:resp) { subject.send :url_parts, url: 'https://www.chowly.com/test' }

      it 'with correct host' do
        expect(resp[0]).to eq 'https://www.chowly.com/'
      end

      it 'with correct path' do
        expect(resp[1]).to eq 'test'
      end
    end

    context 'parsing url with a port' do
      let(:resp) { subject.send :url_parts, url: 'https://www.chowly.com:8080/test' }

      it 'has a host' do
        expect(resp[0]).to eq 'https://www.chowly.com:8080/'
      end

      it 'has a path' do
        expect(resp[1]).to eq 'test'
      end
    end

    context 'making web requests: GET' do
      let(:resp) { subject.get(url: 'https://test/example.json') }

      it 'gets the chowly homepage' do
        expect(resp.env.body).to eq('fruit' => 'Apple', 'size' => 'Large', 'color' => 'Red')
      end

      it 'json should be auto parsed into a hash' do
        expect(resp.env.request_headers).to eq('Content-Type' => 'application/json', 'Accept-Encoding' => 'gzip,deflate')
      end
    end

    context 'making web requests: POST' do
      let(:resp) { subject.post(url: 'https://test/example') }

      it 'gets the chowly homepage' do
        expect(resp.body).to eq('response' => 'ok')
      end

      it 'json should be auto parsed into a hash' do
        expect(resp.status).to eq 200
      end
    end

    context 'handles http errors: 400' do
      let(:resp) { subject.get(url: 'https://fail/400') }

      it 'throws a bad request exception', :aggregate_failures do
        expect { resp }.to raise_error(ChowlyHttp::BadRequest) do |err|
          expect(err.status).to eq 400
        end
      end
    end

    context 'handles http errors: 401' do
      let(:resp) { subject.get(url: 'https://fail/401') }

      it 'throws a bad request exception', :aggregate_failures do
        expect { resp }.to raise_error(ChowlyHttp::Unauthorized) do |err|
          expect(err.status).to eq 401
        end
      end
    end

    context 'handles http errors: 404', :aggregate_failures do
      let(:resp) { subject.get(url: 'https://fail/404') }

      it 'throws a not found exception' do
        expect { resp }.to raise_error(ChowlyHttp::NotFound) do |err|
          expect(err.status).to eq 404
        end
      end
    end

    context 'handles http errors: 407' do
      let(:resp) { subject.get(url: 'https://fail/407') }

      it 'throws a proxy auth exception', :aggregate_failures do
        expect { resp }.to raise_error(ChowlyHttp::ProxyAuthenticationRequired) do |err|
          expect(err.status).to eq 407
        end
      end
    end

    context 'handles http errors: 500' do
      let(:resp) { subject.get(url: 'https://fail/500') }

      it 'throws a internal server error exception', :aggregate_failures do
        expect { resp }.to raise_error(ChowlyHttp::InternalServerError) do |err|
          expect(err.status).to eq 500
        end
      end
    end

    context 'handles http errors: 502' do
      let(:resp) { subject.get(url: 'https://fail/502') }

      it 'throws a bad gateway exception', :aggregate_failures do
        expect { resp }.to raise_error(ChowlyHttp::BadGateway) do |err|
          expect(err.status).to eq 502
        end
      end
    end

    context 'handles http errors: 462' do
      let(:resp) { subject.get(url: 'https://fail/462') }

      it 'throws a generic request exception', :aggregate_failures do
        expect { resp }.to raise_error(ChowlyHttp::Errors::ResponseCodeError) do |err|
          expect(err.status).to eq 462
        end
      end
    end

    context 'handles http redirect: 301' do
      let(:resp) { subject.get(url: 'https://redir/301') }

      it 'resp location is dest' do
        expect(resp.env.url.to_s).to eq 'https://dest/ok'
      end
    end

    context 'handles http redirect: 302' do
      let(:resp) { subject.get(url: 'https://redir/302') }

      it 'resp location is dest' do
        expect(resp.env.url.to_s).to eq 'https://dest/ok'
      end
    end

    context 'handles http redirect: 302 when follow_redirects is false' do
      let(:resp) { subject.get(url: 'https://redir/302', follow_redirects: false) }
      let(:body) { 'Redir 302' }

      it 'resp location is dest' do
        expect(resp.body).to eq(body)
      end
    end

    context 'handles http redirect: 302 POST' do
      let(:resp) { subject.post(url: 'https://redir/302', body: { resp: 'POST OK' }) }

      it 'resp location is dest' do
        expect(resp.body['resp']).to eq 'POST OK'
      end
    end
  end
end
