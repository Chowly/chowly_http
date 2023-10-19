# frozen_string_literal: true

describe Faraday::RackBuilder do
  let(:connection) do
    OpenStruct.new(
      parallel_manager: nil,
      ssl: nil
    )
  end

  let(:request) do
    a = OpenStruct.new(
      body: 'ok',
      path: '/',
      params: {},
      options: OpenStruct.new(params_encode: nil),
      headers: {},
      proxy_headers: { 'proxy' => 'headers' }
    )
  end

  let(:env) { subject.build_env(connection, request) }

  before do
    allow(request).to receive(:method).and_return('GET')
    allow(connection).to receive(:build_exclusive_url).and_return('http://wwww.a.com/a')
  end

  it 'sets env proxy_headers' do
    expect(env.proxy_headers).to eq(request.proxy_headers)
  end
end
