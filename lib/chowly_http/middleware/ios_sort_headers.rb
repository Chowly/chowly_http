# frozen_string_literal: true

module ChowlyHttp
  module Middleware
    class IosSortHeaders

      def initialize(app, options={})
        @app = app
        @options = options
      end

      def call(env)
        # do something with the request
        ideal_sort = ['X-NewRelic-ID', 'Accept-Encoding', 'Accept', 'Cookie', 'Accept-Language', 'Connection', :'User-Agent']
        headers = env[:request_headers]
        sorted_headers = {}
        ideal_sort.each do |k|
          sorted_headers[k] = headers[k]
        end
        puts sorted_headers.inspect
        sorted_headers['User-Agent'] = nil
        sorted_headers[:'User-Agent'] = headers[:'User-Agent']

        env[:request_headers] = sorted_headers

        @app.call(env).on_complete do |env|
          # do something with the response
          # env[:response] is now filled in
        end
      end

    end
  end
end

Faraday::Request.register_middleware ios_sort_headers: ChowlyHttp::Middleware::IosSortHeaders
