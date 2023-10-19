# frozen_string_literal: true

describe Ethon::Curls::Options do
  it 'has an option defined for proxy headers' do
    expect(Ethon::Curls::Options::EASY_OPTIONS[:proxyheader]).to be_present
  end

  it 'has an option defined for proxy headers type is curl_slist' do
    expect(Ethon::Curls::Options::EASY_OPTIONS[:proxyheader][:type]).to eq(:curl_slist)
  end

  it 'has an option defined for proxy headers opt is' do
    expect(Ethon::Curls::Options::EASY_OPTIONS[:proxyheader][:opt]).to eq(10_228)
  end
end
