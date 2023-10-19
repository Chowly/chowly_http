# frozen_string_literal: true

module Faraday
  module ProxyHeader

    def self.included(base)
      base.attr_accessor :proxy_headers
    end

  end
end
