# frozen_string_literal: true

describe ChowlyHttp::Errors::ResponseCodeError do
  context 'tests response code error' do
    describe 'message' do
      let!(:resp) { subject.message }

      it 'with correct response' do
        expect(resp).to eq ''
      end
    end

    describe 'body' do
      let!(:resp) { subject.body }

      it 'with correct response' do
        expect(resp).to eq ''
      end
    end

    describe 'headers' do
      let!(:resp) { subject.headers }

      it 'with correct response' do
        expect(resp).to eq ''
      end
    end
  end

  describe 'status' do
    subject { described_class.new(ex).status }

    context 'when response is a Faraday::Response' do
      let(:ex) { Faraday::ClientError.new('some exception', response) }
      let(:response) { Faraday::Response.new(status: 'blah') }

      it { is_expected.to eq 'blah' }
    end
  end

end
