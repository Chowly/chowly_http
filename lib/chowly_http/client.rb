# frozen_string_literal: true

#
# ChowlyHttp
# A Shared HTTP library to standardize HTTP calls for chowly.
# Based on Faraday / We-Call and Typheous
#
module ChowlyHttp
  class Client

    attr_accessor :http_clients, :base_url, :app, :timeout, :open_timeout, :quick, :debug, :common_headers,
                  :verify_ssl, :params_encoder, :follow_redirects, :raw, :proxy, :http_version, :logger

    #
    # initialize - Make an new instance of the client
    #
    # @param [String] app The name of the app or segment, helps with logging.
    # @param [String] base_url The base url for client if you wish to set a default
    # @param [Integer] timeout Timeout in seconds.
    # @param [boolean] quick Determines if the client should return the response or the body
    # @param [Hash] common_headers Headers to send with every client reqeust
    # @param [Logger] a tagged logger
    #
    def initialize(app: nil, proxy: nil, base_url: nil, timeout: nil, open_timeout: nil, quick: nil, debug: false, common_headers: {}, http_version: nil, verify_ssl: true, raw: false, params_encoder: nil, follow_redirects: true, logger: nil)
      self.http_clients   = {}
      self.timeout        = timeout || 15
      self.open_timeout   = open_timeout || 15
      self.app            = app || 'Chowly'
      self.base_url       = base_url
      self.common_headers = { '*' => common_headers }
      self.quick          = quick
      self.verify_ssl     = verify_ssl
      self.debug          = debug
      self.params_encoder = params_encoder
      self.follow_redirects = follow_redirects
      self.http_version = http_version
      self.proxy = proxy
      self.raw = raw
      self.logger = Logger.new(STDOUT)
    end

    #
    # request - Drys up the different request methods into one place to setup calls
    #
    # @param [Symbol] method The HTTP method for the request (GET, POST, PUT, etc)
    # @param [String] url A Url
    # @param [Hash] headers Request headers
    # @param [Hash] body A payload to post to the server
    #
    # @return [Faraday::Response] The faraday response for the request
    #
    def request(method:, url:, headers: {}, body: {}, proxy: nil, proxy_headers: nil, quick: nil, follow_redirects: nil)
      proxy ||= self.proxy
      conn, path = nil
      if url.start_with?('http')
        full_url = url
        conn    = get_connection(url: url, proxy: proxy, follow_redirects: follow_redirects)
        _, path = url_parts(url: url)
      else
        full_url = "#{self.base_url}#{url}"
        conn = get_connection(url: full_url, proxy: proxy, follow_redirects: follow_redirects)
        _, path = url_parts(url: full_url)
      end

      quick ||= self.quick
      quick = quick.nil? ? false : quick

      default_headers = {
        'Content-Type' => 'application/json'
      }
      configured_headers = default_headers.merge(headers_for_url(url: url))
      headers            = configured_headers.merge(headers).compact

      is_json = headers.fetch('Content-Type', nil).to_s.downcase.include?('json')

      external_request_id = SecureRandom.hex(4) # Jack: Used to group logs later when searching.
      logger.info(tags: ["ExtReqID=#{external_request_id}", 'STARTED'], message: "#{method.upcase} \"#{full_url}\"")
      logger.info(tags: ["ExtReqID=#{external_request_id}", 'HEADERS'], message: headers || {})
      logger.info(tags: ["ExtReqID=#{external_request_id}", 'PROXY'], message: proxy || 'nil')
      logger.info(tags: ["ExtReqID=#{external_request_id}", 'PROXY HEADERS'], message: proxy_headers || {})
      logger.info(tags: ["ExtReqID=#{external_request_id}", 'BODY'], message: body)
      external_request_start_time = Time.now

      begin
        resp = if method == :options
                 conn.run_request(method, path, nil, headers) do |req|
                   req.proxy_headers = proxy_headers if proxy_headers.present?
                   req.body = body.to_json if body.present? && !body.is_a?(String) && is_json
                 end
               else
                 conn.send(method, path, body) do |req|
                   req.headers = headers if headers.present?
                   req.proxy_headers = proxy_headers if proxy_headers.present?
                   req.body = body.to_json if body.present? && !body.is_a?(String) && is_json
                 end
               end

        logger.info(tags: ["ExtReqID=#{external_request_id}", 'COMPLETED'], message: "#{resp.status} #{resp.reason_phrase} in #{Time.now - external_request_start_time}ms")
        logger.info(tags: ["ExtReqID=#{external_request_id}", 'RESP BODY'], message: resp.body)
        logger.info(tags: ["ExtReqID=#{external_request_id}", 'RESP HEADERS'], message: resp.headers)
        return resp.body if quick
        resp
      rescue Faraday::ServerError => e
        resp_err          = ChowlyHttp::Errors::ResponseCodeError.new(e.message)
        resp_err.response = e.response
        ChowlyHttp::Exceptions.raise_error(resp_err)
      rescue Faraday::ConnectionFailed => e
        resp_err          = ChowlyHttp::Errors::ResponseCodeError.new(e.message)
        resp_err.response = { status: 407 }

        logger.info(tags: ["ExtReqID=#{external_request_id}", 'COMPLETED'], message: "407 Proxy Authentication Required in #{Time.now - external_request_start_time}ms")

        ChowlyHttp::Exceptions.raise_error(resp_err)
      rescue Faraday::TimeoutError => e
        logger.info(tags: ["ExtReqID=#{external_request_id}", 'COMPLETED'], message: "Request Timed out after #{Time.now - external_request_start_time}ms")
        raise ChowlyHttp::Errors::TimeoutError, 'Connection Timed Out.'
      rescue Faraday::ClientError => e
        logger.info(tags: ["ExtReqID=#{external_request_id}", 'COMPLETED'], message: "#{e.response[:status]} in #{Time.now - external_request_start_time}ms")
        logger.info(tags: ["ExtReqID=#{external_request_id}", 'RESP BODY'], message: e.response[:body])
        logger.info(tags: ["ExtReqID=#{external_request_id}", 'RESP HEADERS'], message: e.response[:headers])
        logger.info(tags: ["ExtReqID=#{external_request_id}", 'ERROR MESSAGE'], message: e.message)
        resp_err = ChowlyHttp::Errors::ResponseCodeError.new(e)
        ChowlyHttp::Exceptions.raise_error(resp_err)
      end
    end

    #
    # get - Send a HTTP get to an endpoint
    #
    # @param [String] url A URL
    # @param [Hash] headers HTTP Headers for the request
    #
    # @return [Faraday::Response] The response object for the request
    #
    def get(url:, headers: {}, params: {}, quick: nil, follow_redirects: nil)
      request(method: :get, url: url, body: params, headers: headers, quick: quick, follow_redirects: follow_redirects)
    end

    #
    # post - Send a HTTP Post to an endpoint
    #
    # @param [String] url A URL
    # @param [Hash] body A payload for the post, usually a hash, will be converted to json
    # @param [Hash] headers HTTP Headers for the request
    #
    # @return [Faraday::Response] The response object for the request
    #
    def post(url:, body: {}, headers: {}, quick: nil, follow_redirects: nil)
      request(method: :post, url: url, body: body, headers: headers, quick: quick, follow_redirects: follow_redirects)
    end

    #
    # put - Send a HTTP Put to an endpoint
    #
    # @param [String] url A URL
    # @param [Hash] body A payload for the put, usually a hash, will be converted to json
    # @param [Hash] headers HTTP Headers for the request
    #
    # @return [Faraday::Response] The response object for the request
    #
    def put(url:, body: {}, headers: {}, quick: nil, follow_redirects: nil)
      request(method: :put, url: url, body: body, headers: headers, quick: quick, follow_redirects: follow_redirects)
    end

    #
    # patch - Send a HTTP Patch to an endpoint
    #
    # @param [String] url A URL
    # @param [Hash] body A payload for the put, usually a hash, will be converted to json
    # @param [Hash] headers HTTP Headers for the request
    #
    # @return [Faraday::Response] The response object for the request
    #
    def patch(url:, body: {}, headers: {}, quick: nil, follow_redirects: nil)
      request(method: :patch, url: url, body: body, headers: headers, quick: quick, follow_redirects: follow_redirects)
    end

    #
    # delete - Send a HTTP Patch to an endpoint
    #
    # @param [String] url A URL
    # @param [Hash] headers HTTP Headers for the request
    #
    # @return [Faraday::Response] The response object for the request
    #
    def delete(url:, headers: {}, quick: nil, follow_redirects: nil)
      request(method: :delete, url: url, headers: headers, quick: quick, follow_redirects: follow_redirects)
    end

    private

      #
      # get_connection - Find or creates a connection for a given domain
      #
      # @param [String] url A URL
      #
      # @return [Faraday::Connection] A connection tied to the requested domain
      #
      def get_connection(url:, proxy: nil, follow_redirects: nil)
        proxy = proxy.presence || self.proxy

        host, = url_parts(url: url)
        env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'unknown'

        follow_redirects = !follow_redirects.nil? ? follow_redirects : self.follow_redirects

        self.http_clients[proxy.to_s] ||= {}
        self.http_clients[proxy.to_s][host] ||= {}
        self.http_clients[proxy.to_s][host][follow_redirects] ||= Chow::Call::Connection.new(host: host, app: self.app, env: env, timeout: timeout, open_timeout: open_timeout) do |conn|
          conn.ssl[:verify] = self.verify_ssl
          conn.request  :url_encoded
          conn.response :json, content_type: /\bjson(Camel)?/ unless self.raw
          conn.response :raise_error
          conn.response :follow_redirects, limit: 3, standards_compliant: true if follow_redirects
          conn.response :logger, ::Logger.new(STDOUT), bodies: true if self.debug
          conn.proxy = Faraday::ProxyOptions.from(proxy) if proxy.present?
          conn.options.params_encoder = self.params_encoder || ChowlyHttp::UnorderedEncoder
          conn.adapter :typhoeus, http_version: self.http_version if self.http_version.present?
        end
      end

      #
      # headers_for_url - Returns headers configured for a specific request
      #
      # @param [String] url The url to lookup the related headers for.
      # @param [String] state A key in case certain headers should be applied to certain requests only
      #
      # @return [Hash] All headers that apply to a request
      #
      def headers_for_url(url:, state: 'default')
        host           = URI.parse(url).host
        global_headers = self.common_headers.fetch('*', {})
        host_headers   = self.common_headers.fetch("#{host}-#{state}", {})
        global_headers.merge(host_headers)
      end

      #
      # url_parts - Convert a url into the host and path portion
      #
      # @param [String] url A URL
      #
      # @return [string, string] The two url parts relevant to Faraday
      #
      def url_parts(url:)
        uri    = URI.parse(url)
        port   = uri.default_port == uri.port ? '' : ":#{uri.port}"
        domain = "#{uri.scheme}://#{uri.host}#{port}/"
        path   = url.sub(domain, '')
        [domain, path]
      end

  end
end
