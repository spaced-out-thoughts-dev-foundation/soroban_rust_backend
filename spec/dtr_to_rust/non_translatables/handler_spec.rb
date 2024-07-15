require 'spec_helper'

RSpec.describe SorobanRustBackend::NonTranslatables::Handler do
  describe '.generate' do
    context 'when non_translatables' do
      let(:non_translatables) do
        'use std::collections::HashMap;'
      end

      let(:expected_output) do
        'use std::collections::HashMap;'
      end

      it 'generates the correct non_translatables' do
        expect(described_class.generate(non_translatables)).to eq(expected_output)
      end
    end
  end
end
