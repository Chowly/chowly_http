# frozen_string_literal: true

describe ChowlyHttp::Client do
  context 'tests ChowlyHttp client' do
    describe 'connection settings' do
      subject { described_class.new(verify_ssl: false) }

      let(:connection) { subject.send :get_connection, url: 'https://www.chowly.com' }

      it 'sets ssl verification false' do
        expect(connection.ssl.verify).to eq(false)
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

    describe 'sensitive data redaction (TEAM-14890)' do
      describe '#redact_headers' do
        subject { described_class.new }

        let(:headers) do
          {
            'Authorization' => 'Bearer super-secret',
            'Proxy-Authorization' => 'Basic super-secret',
            'MxAuthorization' => 'mx-secret',
            'X-Auth-Token' => 'x-auth-secret',
            'API-AUTHENTICATION' => 'revel-key:revel-secret',
            'X-Breadcrumb-Password' => 'breadcrumb-secret',
            'Api-Key' => 'api-secret',
            'X-Api-Key' => 'x-api-secret',
            'Cookie' => 'session=abc',
            'Set-Cookie' => 'session=abc',
            'X-Request-Token' => 'token-secret',
            'Content-Type' => 'application/json',
            'X-Trace-Id' => 'trace-123',
            'x-brd-error-code' => 'MENU_SYNC_FAILED'
          }
        end

        let(:redacted) { subject.send(:redact_headers, headers) }

        it 'redacts every sensitive header', :aggregate_failures do
          %w[
            Authorization Proxy-Authorization MxAuthorization X-Auth-Token
            API-AUTHENTICATION X-Breadcrumb-Password Api-Key X-Api-Key
            Cookie Set-Cookie X-Request-Token
          ].each do |name|
            expect(redacted[name]).to eq('[REDACTED]')
          end
        end

        it 'preserves non-sensitive headers, including x-brd-error-code for Datadog monitor 328681408', :aggregate_failures do
          expect(redacted['Content-Type']).to eq('application/json')
          expect(redacted['X-Trace-Id']).to eq('trace-123')
          expect(redacted['x-brd-error-code']).to eq('MENU_SYNC_FAILED')
        end

        it 'never leaks a secret value anywhere in the result' do
          expect(redacted.values.join(' ')).not_to include('secret')
        end

        it 'is resilient to a nil headers payload' do
          expect(subject.send(:redact_headers, nil)).to be_nil
        end
      end

      describe '#sanitize_proxy' do
        subject { described_class.new }

        it 'strips inline credentials from a proxy url' do
          expect(subject.send(:sanitize_proxy, 'http://brd-customer-x:PASSWORD@brd.superproxy.io:22225'))
            .to eq('http://[REDACTED]@brd.superproxy.io:22225')
        end

        it 'leaves a credential-free proxy url unchanged' do
          expect(subject.send(:sanitize_proxy, 'http://brd.superproxy.io:22225'))
            .to eq('http://brd.superproxy.io:22225')
        end

        it 'returns the nil placeholder when there is no proxy' do
          expect(subject.send(:sanitize_proxy, nil)).to eq('nil')
        end
      end

      describe 'logging through a real request' do
        let(:log_entries) { [] }

        let(:recording_logger) do
          Class.new do
            def initialize(sink)
              @sink = sink
            end

            def info(*args, **kwargs)
              @sink << (kwargs.empty? ? { message: args.first } : kwargs)
            end

            def method_missing(*); end

            def respond_to_missing?(*)
              true
            end
          end.new(log_entries)
        end

        let(:logged_tags) { log_entries.flat_map { |e| e[:tags] || [] } }

        def message_for(tag)
          entry = log_entries.find { |e| (e[:tags] || []).include?(tag) }
          entry && entry[:message]
        end

        context 'with debug disabled (default)' do
          let(:client) { described_class.new(logger: recording_logger) }

          before do
            client.get(
              url: 'https://test/example.json',
              headers: { 'Authorization' => 'Bearer secret-token', 'X-Api-Key' => 'api-secret' }
            )
          end

          it 'redacts sensitive request headers before logging', :aggregate_failures do
            headers = message_for('HEADERS')
            expect(headers['Authorization']).to eq('[REDACTED]')
            expect(headers['X-Api-Key']).to eq('[REDACTED]')
            expect(headers['Content-Type']).to eq('application/json')
          end

          it 'does not log the request body at INFO' do
            expect(logged_tags).not_to include('BODY')
          end

          it 'does not log the response body at INFO' do
            expect(logged_tags).not_to include('RESP BODY')
          end

          it 'still logs the (redacted) response headers' do
            expect(logged_tags).to include('RESP HEADERS')
          end
        end

        context 'with debug enabled' do
          let(:client) { described_class.new(logger: recording_logger, debug: true) }

          before { client.get(url: 'https://test/example.json') }

          it 'opts back into request and response body logging', :aggregate_failures do
            expect(logged_tags).to include('BODY')
            expect(logged_tags).to include('RESP BODY')
          end
        end

        context "with debug enabled, Faraday's own logger must not leak credentials to STDOUT" do
          let(:captured_stdout) { StringIO.new }
          let(:client) { described_class.new(logger: recording_logger, debug: true) }

          before do
            stub_const('STDOUT', captured_stdout)
            client.get(
              url: 'https://test/example.json',
              headers: { 'Authorization' => 'Bearer faraday-leak-canary' }
            )
          end

          it 'redacts the bearer on the Faraday header dump line', :aggregate_failures do
            output = captured_stdout.string
            expect(output).not_to include('faraday-leak-canary')
            expect(output).to include('[REDACTED]')
          end
        end
      end
    end
  end
end
