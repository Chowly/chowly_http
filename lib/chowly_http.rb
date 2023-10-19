# frozen_string_literal: true

require 'resolv'
require 'typhoeus'
require 'chow-call'
require 'ethon/proxy_header_patch'
require 'faraday/proxy_header'
require 'faraday/response_proxy_header'
require 'faraday/proxy_rack_builder'
require 'faraday/env_proxy_header'
require 'faraday/patch'
require 'typhoeus/proxy_patch'

require 'faraday_middleware'
require 'chowly_http/client'
require 'faraday_middleware'
require 'chowly_http/errors/response_code_error'
require 'chowly_http/errors/exceptions'
require 'chowly_http/errors/timeout_error'
require 'chowly_http/middleware/ios_sort_headers'
require 'chowly_http/encoders/unordered_encoder'

require 'ethon/easy_cleanup_mutex_patch'

module ChowlyHttp

end
