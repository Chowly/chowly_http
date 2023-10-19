# frozen_string_literal: true

describe ChowlyRestClient do
  it 'defines exception types', aggregate_failures: true do
    expect(defined?(ChowlyRestClient::BadGateway)).to eq('constant')
    expect(defined?(ChowlyRestClient::Unauthorized)).to eq('constant')
    expect(defined?(ChowlyRestClient::Conflict)).to eq('constant')
    expect(defined?(ChowlyRestClient::NotFound)).to eq('constant')
  end
end
