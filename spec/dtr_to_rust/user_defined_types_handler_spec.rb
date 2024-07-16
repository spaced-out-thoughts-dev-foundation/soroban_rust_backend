require 'spec_helper'

RSpec.describe SorobanRustBackend::UserDefinedTypesHandler do
  describe '.generate' do
    context 'when struct' do
      let(:user_defined_type) do
        DTRCore::UserDefinedType.new(
          'Person_STRUCT',
          [
            { name: 'name', type: 'String' },
            { name: 'age', type: 'i32' }
          ]
        )
      end

      let(:expected_output) do
        <<~RUST
          #[contracttype]
          #[derive(Clone, Debug, Eq, PartialEq)]
          pub struct Person {
              pub name: String,
              pub age: i32,
          }

        RUST
      end

      it 'generates the correct struct' do
        expect(described_class.generate(user_defined_type)).to eq(expected_output)
      end
    end

    context 'when variant enum' do
      let(:user_defined_type) do
        DTRCore::UserDefinedType.new(
          'Person_ENUM',
          [
            { name: 'Robot', type: '(i32)' },
            { name: 'Astronaut', type: '()' },
            { name: 'DogWhisperer', type: '(String, Boolean)' }
          ]
        )
      end

      let(:expected_output) do
        <<~RUST
          #[contracttype]
          #[derive(Clone, Debug, Eq, PartialEq)]
          pub enum Person {
              Robot(i32),
              Astronaut,
              DogWhisperer(String,  bool),
          }

        RUST
      end

      it 'generates the correct struct' do
        expect(described_class.generate(user_defined_type)).to eq(expected_output)
      end
    end

    context 'when type based numeric enum' do
      let(:user_defined_type) do
        DTRCore::UserDefinedType.new(
          'Person_ENUM',
          [
            { name: 'Robot', type: '0' },
            { name: 'Astronaut', type: '1' },
            { name: 'DogWhisperer', type: '2' }
          ]
        )
      end

      let(:expected_output) do
        <<~RUST
          #[contracttype]
          #[derive(Clone, Debug, Eq, PartialEq)]
          pub enum Person {
              Robot = 0,
              Astronaut = 1,
              DogWhisperer = 2,
          }

        RUST
      end

      it 'generates the correct struct' do
        expect(described_class.generate(user_defined_type)).to eq(expected_output)
      end
    end

    context 'when value based numeric enum' do
      let(:user_defined_type) do
        DTRCore::UserDefinedType.new(
          'Person_ENUM',
          [
            { name: 'Robot', value: '0' },
            { name: 'Astronaut', value: '1' },
            { name: 'DogWhisperer', value: '2' }
          ]
        )
      end

      let(:expected_output) do
        <<~RUST
          #[contracttype]
          #[derive(Clone, Debug, Eq, PartialEq)]
          #[repr(u32)]
          pub enum Person {
              Robot = 0,
              Astronaut = 1,
              DogWhisperer = 2,
          }

        RUST
      end

      it 'generates the correct struct' do
        expect(described_class.generate(user_defined_type)).to eq(expected_output)
      end
    end

    context 'when error enum' do
      let(:user_defined_type) do
        DTRCore::UserDefinedType.new(
          'ErrorForPerson_ENUM',
          [
            { name: 'NotARobot', value: '0' },
            { name: 'NotAnAstronaut', value: '1' },
            { name: 'NotADogWhisperer', value: '2' }
          ]
        )
      end

      let(:expected_output) do
        <<~RUST
          #[contracterror]
          #[derive(Copy, Clone, Debug, Eq, PartialEq, PartialOrd, Ord)]
          #[repr(u32)]
          pub enum ErrorForPerson {
              NotARobot = 0,
              NotAnAstronaut = 1,
              NotADogWhisperer = 2,
          }

        RUST
      end

      it 'generates the correct struct' do
        expect(described_class.generate(user_defined_type)).to eq(expected_output)
      end
    end
  end
end
