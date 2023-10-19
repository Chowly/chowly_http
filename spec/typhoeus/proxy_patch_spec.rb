# frozen_string_literal: true

describe Typhoeus::Response do
  subject { described_class.new({}) }

  it 'can set proxy_headers' do
    subject.proxy_headers = {}
    expect(subject.proxy_headers).to eq({})
  end
end
