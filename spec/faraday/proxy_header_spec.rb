# frozen_string_literal: true

describe Faraday::ProxyHeader do
  subject { dummy.new }

  let(:dummy) do
    a = Class.new
    a.include(described_class)
  end

  it 'allows set proxy_headers' do
    subject.proxy_headers = {}
    expect(subject.proxy_headers).to eq({})
  end
end
