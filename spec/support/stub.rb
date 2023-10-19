# frozen_string_literal: true

module ChowlyHttp
  class Testing

    extend WebMock::API
    def self.stub!
      # Stub out web requests here.

      stub_request(:get, 'https://test/example.json')
        .to_return(status: 200, body: File.read(File.expand_path('../data/example.json', __dir__)), headers: { content_type: 'application/json' })

      stub_request(:post, 'https://test/example')
        .with(
          headers: {
            'Content-Type' => 'application/json'
          }
        )
        .to_return(status: 200, body: '{"response": "ok"}', headers: { content_type: 'application/json' })

      stub_request(:get, %r{https:\/\/fail\/\d+})
        .to_return do |request|
          url = request.uri.display_uri.to_s
          code = url.scan(%r{https:\/\/fail\/(\d+)}).flatten.first.to_i
          { status: code, body: "Error #{code}" }
        end

      stub_request(:get, %r{https:\/\/redir/\d+})
        .to_return do |request|
          url = request.uri.display_uri.to_s
          code = url.scan(%r{https:\/\/redir\/(\d+)}).flatten.first.to_i
          { status: code, body: "Redir #{code}", headers: { 'Location': 'https://dest/ok' } }
        end

      stub_request(:post, %r{https:\/\/redir/\d+})
        .to_return do |request|
          url = request.uri.display_uri.to_s
          code = url.scan(%r{https:\/\/redir\/(\d+)}).flatten.first.to_i
          { status: code, body: "Redir #{code}", headers: { 'Location': 'https://dest/ok' } }
        end

      stub_request(:get, 'https://dest/ok')
        .to_return(status: 200, body: '{"response": "GET ok"}', headers: { content_type: 'application/json' })

      stub_request(:post, 'https://dest/ok')
        .to_return do |request|
          { status: 200, body: request.body, headers: { content_type: 'application/json' } }
        end
    end

  end
end
