# frozen_string_literal: true

describe Faraday::EnvProxyHeader do
  subject { dummy.new }

  let(:dummy) do
    a = Class.new
    a.include(described_class)
  end

  it 'allows set proxy_headers' do
    subject.proxy_headers = {}
    expect(subject.proxy_headers).to eq({})
  end

  it 'allows set response_proxy_headers' do
    subject.response_proxy_headers = {}
    expect(subject.response_proxy_headers).to eq({})
  end
end
