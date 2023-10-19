# frozen_string_literal: true

module Ethon
  class Easy
    # This module contains the logic around adding headers to libcurl.
    #
    # @api private
    module ProxyHeader

      # Return proxy_headers, return empty hash if none.
      #
      # @example Return the proxy_headers.
      #   easy.proxy_headers
      #
      # @return [ Hash ] The proxy_headers.
      def proxy_headers
        @proxy_headers ||= {}
      end

      # Set the proxy_headers.
      #
      # @example Set the proxy_headers.
      #   easy.proxy_headers = {'User-Agent' => 'ethon'}
      #
      # @param [ Hash ] proxy_headers The proxy_headers.
      def proxyheader=(proxy_headers)
        proxy_headers ||= {}
        proxy_header_list = nil
        proxy_headers.each do |k, v|
          proxy_header_list = Curl.slist_append(proxy_header_list, compose_proxy_headers(k, v))
        end
        Curl.set_option(:proxyheader, proxy_header_list, handle)

        @proxy_header_list = proxy_header_list && FFI::AutoPointer.new(proxy_header_list, Curl.method(:slist_free_all))
      end

      # Return proxy_header_list.
      #
      # @example Return proxy_headers_list.
      #   easy.proxy_header_list
      #
      # @return [ FFI::Pointer ] The header list.
      def proxy_header_list
        @proxy_header_list
      end

      # Compose libcurl header string from key and value.
      # Also replaces null bytes, because libcurl will complain
      # otherwise.
      #
      # @example Compose header.
      #   easy.compose_header('User-Agent', 'Ethon')
      #
      # @param [ String ] key The header name.
      # @param [ String ] value The header value.
      #
      # @return [ String ] The composed header.
      def compose_proxy_headers(key, value)
        Util.escape_zero_byte("#{key}: #{value}")
      end

    end
  end
end
