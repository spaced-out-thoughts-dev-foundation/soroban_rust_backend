require 'spec_helper'

RSpec.describe SorobanRustBackend::FunctionHandler do
  describe '.generate' do
    context 'when function with inputs and output but no instructions' do
      let(:function) do
        DTRCore::Function.new(
          'add',
          [
            { name: 'a', type_name: 'Integer' },
            { name: 'b', type_name: 'Integer' }
          ],
          'Integer',
          []
        )
      end

      let(:expected_output) do
        <<~RUST
          pub fn add(a: i128, b: i128) -> i128 {
            let mut Thing_to_return: i128;
          }
        RUST
      end

      it 'generates the correct function' do
        expect(described_class.generate(function, false, [], []).gsub("\t", '').gsub(' ',
                                                                                     '').gsub("\n", '')).to eq(expected_output.gsub("\t", '').gsub(
                                                                                       ' ', ''
                                                                                     ).gsub("\n", ''))
      end
    end

    context 'when function instantiates a user defined type' do
      let(:function) do
        DTRCore::Function.new(
          'make_foobar_udt',
          [],
          nil,
          [
            ins(instruction: 'instantiate_object', inputs: %w[UDT Foobar 0 "hello" false],
                assign: 'udt_result', scope: 0, id: 0)
          ]
        )
      end

      let(:expected_output) do
        <<~RUST
          pub fn make_foobar_udt() {
            let mut udt_result = Foobar { num: 0, name: String::from_str(&env, "hello"), is_active: false };
          }
        RUST
      end

      let(:udts) do
        [
          DTRCore::UserDefinedType.new(
            'Foobar',
            [
              { name: 'num', type_name: 'Integer' },
              { name: 'name', type_name: 'String' },
              { name: 'is_active', type_name: 'Boolean' }
            ]
          )
        ]
      end

      it 'generates the correct function' do
        result = described_class.generate(function, false, udts, [])
        expect(result.gsub("\t", '').gsub(' ',
                                          '').gsub("\n", '')).to eq(expected_output.gsub("\t", '').gsub(
                                            ' ', ''
                                          ).gsub("\n", ''))
      end
    end

    context 'when function with inputs, output, and instructions' do
      let(:function) do
        DTRCore::Function.new(
          'add',
          [
            { name: 'a', type_name: 'Integer' },
            { name: 'b', type_name: 'Integer' }
          ],
          'Integer',
          [
            # 0
            ins(instruction: 'assign', inputs: ['a'], assign: 'RANGE_START_1', scope: 0, id: 0),
            # 1
            ins(instruction: 'assign', inputs: ['b'], assign: 'RANGE_END_2', scope: 0, id: 1),
            # 2
            ins(instruction: 'instantiate_object', inputs: %w[Range RANGE_START_1 RANGE_END_2],
                assign: 'range_thing', scope: 0, id: 2),
            # 3
            ins(instruction: 'assign', inputs: ['range_thing'], assign: 'ITERATOR_1', scope: 0, id: 3),
            # 4
            ins(instruction: 'evaluate', inputs: %w[start ITERATOR_1], assign: 'i', scope: 0, id: 4),
            # 5
            ins(instruction: 'end_of_iteration_check', inputs: %w[i ITERATOR_1], assign: 'CHECK_CONDITION_ASSIGNMENT_2',
                scope: 0, id: 5),
            # 6
            ins(instruction: 'jump', inputs: %w[CHECK_CONDITION_ASSIGNMENT_2 6], scope: 0, id: 6),
            # 7
            ins(instruction: 'add', inputs: %w[sum i], assign: 'sum', scope: 6, id: 7),
            # 8
            ins(instruction: 'increment', inputs: %w[i ITERATOR_1], scope: 6, id: 8),
            # 9
            ins(instruction: 'goto', inputs: ['5'], scope: 6, id: 9),
            # 10
            ins(instruction: 'return', inputs: ['sum'], scope: 0, id: 10)
          ]
        )
      end

      let(:expected_output) do
        <<~RUST
          pub fn add(a: i128, b: i128) -> i128 {
              let mut Thing_to_return: i128;
              let mut RANGE_START_1 = a;
              let mut RANGE_END_2 = b;
              let mut range_thing = RANGE_START_1..RANGE_END_2;
              let mut ITERATOR_1 = range_thing;
              let mut OPTION_i = ITERATOR_1.next();
              while let Some(i) = OPTION_i {
                  let mut sum = sum + i;
                  OPTION_i = ITERATOR_1.next();
              }
              return sum;
          }

        RUST
      end

      it 'generates the correct function' do
        result = described_class.generate(function, false, [], [])
        expect(result.gsub("\t", '').gsub(' ',
                                          '').gsub("\n", '')).to eq(expected_output.gsub("\t", '').gsub(
                                            ' ', ''
                                          ).gsub("\n", ''))
      end
    end
  end
end
