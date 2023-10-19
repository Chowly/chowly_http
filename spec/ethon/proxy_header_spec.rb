# frozen_string_literal: true

describe Ethon::Easy do
  context 'tests Ethon Easy' do
    describe 'proxy headers' do
      let!(:resp) { subject.proxy_headers }

      it 'with correct response' do
        expect(resp).to eq({})
      end
    end

    describe 'proxy header list' do
      let!(:resp) { subject.proxy_header_list }

      it 'with correct response' do
        expect(resp).to eq nil
      end
    end

    describe 'proxy headers' do
      let!(:resp) { subject.proxyheader = [] }

      it 'with correct response' do
        expect(resp).to eq []
      end
    end

    describe 'compose proxy headers' do
      let!(:resp) { subject.compose_proxy_headers(1, 2) }

      it 'with correct response' do
        expect(resp).to eq '1: 2'
      end
    end
  end
end
