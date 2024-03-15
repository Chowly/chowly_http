# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github){ |repo_name| "https://github.com/#{repo_name}.git" }

# Specify your gem's dependencies in chowly_support.gemspec

# this is the new-faraday branch of chow-call at https://github.com/Chowly/chow-call/tree/new-faraday
gem 'chow-call', github: 'Chowly/chow_call', branch: 'next/faraday_2'

gemspec

group :development, :test do
  gem 'http-cookie'
end
