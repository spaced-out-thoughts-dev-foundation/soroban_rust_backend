require 'spec_helper'

RSpec.describe SorobanRustBackend::ContractState::Handler do
  describe '.generate' do
    context 'when state is a String' do
      let(:state) do
        [
          DTRCore::State.new(
            'name',
            'String',
            '"some_initial_value"'
          )
        ]
      end

      let(:expected_output) do
        <<~RUST
          const name: String = String::from_str("some_initial_value");
        RUST
      end

      it 'generates the correct state' do
        expect(described_class.generate(state)).to eq(expected_output)
      end
    end

    context 'when state is a Number' do
      let(:state) do
        [
          DTRCore::State.new(
            'name',
            'BigInteger',
            '100000000'
          )
        ]
      end

      let(:expected_output) do
        <<~RUST
          const name: i128 = 100000000;
        RUST
      end

      it 'generates the correct state' do
        expect(described_class.generate(state)).to eq(expected_output)
      end
    end

    context 'when state is a Symbol' do
      let(:state) do
        [
          DTRCore::State.new(
            'name',
            'Symbol',
            ':some_symbol'
          )
        ]
      end

      let(:expected_output) do
        <<~RUST
          const name: Symbol = symbol_short!(:some_symbol);
        RUST
      end

      it 'generates the correct state' do
        expect(described_class.generate(state)).to eq(expected_output)
      end
    end
  end
end
