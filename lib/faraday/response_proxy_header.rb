# frozen_string_literal: true

module Faraday
  module ResponseProxyHeader

    def proxy_headers
      env.response_proxy_headers || {}
    end

  end
end
