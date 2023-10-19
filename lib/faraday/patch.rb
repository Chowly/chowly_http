# frozen_string_literal: true

Faraday::Adapter::Typhoeus.class_eval do
  # TODO: Redefine as a Chain Alias
  def configure_proxy(req, env)
    proxy = env[:request][:proxy]
    return unless proxy

    req.options[:proxy] = "#{proxy[:uri].scheme}://#{proxy[:uri].host}:#{proxy[:uri].port}"

    if proxy[:user] && proxy[:password]
      req.options[:proxyauth] = :basic
      req.options[:proxyuserpwd] = "#{proxy[:user]}:#{proxy[:password]}"
    end

    req.options[:proxyheader] = env.proxy_headers if env.proxy_headers

    # Probably hacky but it get the response proxies somewhere they can be returned.
    req.on_headers { |response| env.response_proxy_headers = parse_proxy_headers(response.response_headers) }
  end

  def parse_proxy_headers(headers)
    return {} if headers.nil?
    http_lines = 0
    lines = headers.split("\r\n")
    headers_out = {}
    lines.each do |line|
      next if line.blank?
      if line.starts_with?('HTTP/')
        http_lines += 1
        if http_lines > 1
          break
        else
          next
        end
      end
      key, value = line.split(': ')
      headers_out[key] = value
    end
    headers_out
  end
end

Faraday::Response.include Faraday::ResponseProxyHeader
Faraday::Request.include Faraday::ProxyHeader
Faraday::Env.include Faraday::EnvProxyHeader
