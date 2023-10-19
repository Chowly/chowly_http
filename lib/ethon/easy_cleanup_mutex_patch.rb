# frozen_string_literal: true

module Ethon
  class Easy
    module Operations

      @easy_cleanup_mutex = Mutex.new

      def handle
        @handle ||= FFI::AutoPointer.new(Curl.easy_init, lambda do |*args, **kwargs|
          
          @easy_cleanup_mutex.synchronize { Curl.easy_cleanup(*args, **kwargs) } if @easy_cleanup_mutex.present?
        end)
      end

    end
  end
end
