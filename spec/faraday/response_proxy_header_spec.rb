# frozen_string_literal: true

describe Faraday::ResponseProxyHeader do
  subject do
    o = dummy.new
    o.env = OpenStruct.new(response_proxy_headers: { ok: 'ok' })
    o
  end

  let(:dummy) do
    a = Class.new
    a.attr_accessor :env
    a.include(described_class)
  end

  it 'allows set proxy_headers' do
    expect(subject.proxy_headers).to eq(subject.env.response_proxy_headers)
  end
end
