# frozen_string_literal: true

require 'chowly_test/simplecov/profiles/chowly_gems'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'rspec'
require 'chowly_http'
require 'http-cookie'
require 'webmock/rspec'

require 'pry'

ENV['RAILS_ENV'] = 'the_chowly'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

SimpleCov.command_name 'chowly_http'

RSpec.configure do |config|
  config.before do
    WebMock.disable_net_connect!

    ChowlyHttp::Testing.stub!
  end
end
