# frozen_string_literal: true

module ChowlyHttp
  module Errors
    class ResponseCodeError < ::Faraday::ClientError

      attr_accessor :__status, :__message, :response

      def initialize(ex=nil, ex_status=nil)
        if ex.is_a?(Faraday::ClientError)
          self.response  = ex.response
        else
          self.__message = ex
          self.__status  = ex_status
        end
      end

      def message
        [__message, body].compact.join(' | ')
      end

      def status
        return __status if __status
        response = self.response || {}
        return response.status if response.is_a? Faraday::Response
        response.fetch(:status, nil)
      end

      def body
        response = self.response || {}
        return response.body if response.is_a? Faraday::Response
        response.fetch(:body, '')
      end

      def headers
        response = self.response || {}
        return response.headers if response.is_a? Faraday::Response
        response.fetch(:headers, '')
      end

    end
  end
end
