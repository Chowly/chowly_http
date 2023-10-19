lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chowly_http/version'

Gem::Specification.new do |spec|
  spec.name          = 'chowly_http'
  spec.version       = ChowlyHttp::VERSION
  spec.authors       = ['Justin McNally']
  spec.email         = ['justin@chowlyinc.com']

  spec.summary       = 'Chowly Shared HTTP Client'
  spec.description   = 'Standard, http client between gems'
  spec.homepage      = 'http://www.chowlyinc.com'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `find *`.split("\n").uniq.sort.reject(&:empty?)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'chow-call'

  spec.add_dependency 'ethon', '0.13.0'
  spec.add_dependency 'faraday', '~> 1.5.1'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'typhoeus', '~> 1.4'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~>3.6.0'
end
