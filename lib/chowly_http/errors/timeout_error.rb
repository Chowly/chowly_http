# frozen_string_literal: true

module ChowlyHttp
  module Errors
    class TimeoutError < ::Faraday::TimeoutError
    end
  end
end
