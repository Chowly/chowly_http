guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/chowly_http/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
end
