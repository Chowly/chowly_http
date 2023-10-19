# frozen_string_literal: true

require 'spec_helper'

describe ChowlyHttp::UnorderedEncoder do
  context 'when decoding a url string' do
    let(:decoded) { described_class.decode('token=123&_=abc123') }

    it 'puts all params into a hash' do
      expect(decoded).to be_a(Hash)
    end

    it 'extracts token' do
      expect(decoded['token']).to eq('123')
    end

    it 'extracts _' do
      expect(decoded['_']).to eq('abc123')
    end

    it 'keeps key order' do
      expect(decoded.keys).to eq(%w[token _])
    end

    describe '#decode_pair' do
      let(:key) { 'k' }
      let(:value) { 'v' }
      let(:context) { {} }

      before { described_class.send(:decode_pair, key, value, context) }

      it 'adds params to context' do
        expect(context).to eq('k' => 'v')
      end
    end

    describe '#prepare_context' do
      let(:last_subkey) { false }
      let(:is_array) { false }
      let(:subkey) { 'k' }
      let(:context) { {} }

      context 'last_subkey is false and is_array is false' do
        it 'calls new_context' do
          expect(described_class).to receive(:new_context).with(subkey, is_array, context)
          described_class.send(:prepare_context, context, subkey, is_array, last_subkey)
        end
        it 'has a context at k with a hash' do
          described_class.send(:prepare_context, context, subkey, is_array, last_subkey)
          expect(context).to eq('k' => {})
        end
      end

      context 'last_subkey is false and is_array is true' do
        let(:is_array) { true }

        it 'calls new_context' do
          expect(described_class).to receive(:new_context).with(subkey, is_array, context)
          described_class.send(:prepare_context, context, subkey, is_array, last_subkey)
        end
        it 'has a context at k with an array' do
          described_class.send(:prepare_context, context, subkey, is_array, last_subkey)
          expect(context).to eq('k' => [])
        end
      end

      context 'is_array is false and context is an Array whose last element is a hash with the same key as subkey' do
        let(:last_subkey) { true }
        let(:context) { [{ 'k' => [] }] }

        it 'call match_context' do
          expect(described_class).to receive(:match_context).with(context, subkey)
          described_class.send(:prepare_context, context, subkey, is_array, last_subkey)
        end
        it 'returns a new hash' do
          expect(described_class.send(:prepare_context, context, subkey, is_array, last_subkey)).to eq({})
        end
      end

      context 'is_array is false and context is an Array whose last element is a hash with the same key as subkey' do
        let(:last_subkey) { true }
        let(:context) { [{}, { 'a' => [] }] }

        it 'returns last element of context' do
          expect(described_class.send(:prepare_context, context, subkey, is_array, last_subkey)).to eq(context.last)
        end
      end
    end

    describe '#match_context' do
      let(:context) { [{ 'k' => [] }] }
      let(:subkey) { 'k' }

      let!(:retval) { described_class.send(:match_context, context, subkey) }

      context 'when last item in context contains a key the same as subkey' do
        it 'adds a hash to context' do
          expect(context.last).to eq({})
        end
        it 'returns last item in context' do
          expect(retval).to eq(context.last)
        end
      end

      context 'when last item in context is not a Hash' do
        let(:context) { [{ 'k' => [] }, []] }

        it 'adds a hash to context' do
          expect(context.last).to eq({})
        end
        it 'returns last item in context' do
          expect(retval).to eq(context.last)
        end
      end

      context 'when last item in context is a hash and does not contain a key the same as subkey' do
        let(:context) { [{ 'a' => [] }] }

        it 'returns last item in context' do
          expect(retval).to eq(context.last)
        end
      end
    end

    describe '#new_context' do
      let(:subkey) { 'k' }
      let(:is_array) { false }
      let(:context) { {} }

      context 'is_array is true' do
        let(:is_array) { true }
        let!(:retval) { described_class.send(:new_context, subkey, is_array, context) }

        it 'returns an array' do
          expect(retval).to be_a(Array)
        end
        it 'context the subkey key to an array value' do
          expect(context[subkey]).to eq([])
        end
      end

      context 'is_array is false' do
        let!(:retval) { described_class.send(:new_context, subkey, is_array, context) }

        it 'returns an hash' do
          expect(retval).to be_a(Hash)
        end
        it 'context the subkey key to an hash value' do
          expect(context[subkey]).to eq({})
        end
      end

      context 'is_array is true but key is a hash' do
        let(:is_array) { true }
        let(:context) { { 'k' => {} } }

        it 'throws a TypeError' do
          expect { described_class.send(:new_context, subkey, is_array, context) }.to raise_error(TypeError)
        end
      end
    end

    describe '#add_to_context' do
      let(:context) { {} }
      let(:subkey) { 'k' }
      let(:value) { 'abc' }
      let(:is_array) { false }

      before { described_class.send(:add_to_context, is_array, context, value, subkey) }

      context 'is_array is true' do
        let(:is_array) { true }
        let(:context) { [] }

        it 'adds value directly to context' do
          expect(context).to eq([value])
        end
      end

      context 'is_array is false' do
        it 'adds value to the subkey array in the context hash' do
          expect(context[subkey]).to eq(value)
        end
      end
    end
  end

  context 'when encoding a url string' do
    let(:params) do
      {
        'token' => '1',
        '_' => '12345'
      }
    end
    let(:encoded) { described_class.encode(params) }

    it 'keeps order of keys' do
      expect(encoded).to eq('token=1&_=12345')
    end
  end

  describe '#encode_pair' do
    let(:parent) { 'key' }
    let(:value) { 'value' }

    context 'when value is an array' do
      let(:value) { ['value1', 'value 2'] }

      it 'calls encode_array' do
        expect(described_class).to receive(:encode_array).with(parent, value)
        described_class.send(:encode_pair, parent, value)
      end
    end

    context 'when value is a hash' do
      let(:value) { { key: 'val', key2: 'val2' } }

      it 'calls encode_hash' do
        expect(described_class).to receive(:encode_hash).with(parent, value)
        described_class.send(:encode_pair, parent, value)
      end
    end

    context 'when value is a string' do
      it 'returns key=value' do
        expect(described_class.send(:encode_pair, parent, value)).to eq('key=value')
      end
    end
  end

  describe '#encode_hash' do
    let(:parent) { 'key' }
    let(:value) { { 'a' => 1, 'b' => 2, 'c' => 3 } }

    it 'is put into %5B %5D format' do
      expect(described_class.send(:encode_hash, parent, value)).to eq('key%5Ba%5D=1&key%5Bb%5D=2&key%5Bc%5D=3')
    end
  end

  describe '#encode_array' do
    let(:parent) { 'key' }
    let(:value) { [1, 2, 3] }

    it 'is encoded into repeated keys' do
      expect(described_class.send(:encode_array, parent, value)).to eq('key%5B%5D=1&key%5B%5D=2&key%5B%5D=3')
    end
  end
end
