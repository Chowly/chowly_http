# frozen_string_literal: true

require 'ethon/proxy_header'

Ethon::Curls::Options.module_eval do
  option :easy, :proxyheader, :curl_slist, 228
end

Ethon::Easy.include Ethon::Easy::ProxyHeader
