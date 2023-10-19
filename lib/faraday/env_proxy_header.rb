# frozen_string_literal: true

module Faraday
  module EnvProxyHeader

    def self.included(base)
      base.attr_accessor :proxy_headers, :response_proxy_headers
    end

  end
end
