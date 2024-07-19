require 'spec_helper'

RSpec.describe SorobanRustBackend::CodeGenerator do
  describe 'when conditional' do
    context 'when if only' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 2], assign: 'CONDITIONAL_RESULT_1', scope: 0, id: 0),
          # 1
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_1 1], scope: 0, id: 1),
          # 2
          ins(instruction: 'print', inputs: ['"inside 1"'], scope: 1, id: 2),
          # 3
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 3)
        ]
      end

      let(:expected_output) do
        <<~RUST
          let CONDITIONAL_RESULT_1 = 1 == 2;
          if CONDITIONAL_RESULT_1 {
              log!("inside 1");
          }
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when if else' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 2], assign: 'CONDITIONAL_RESULT_1', scope: 0, id: 0),
          # 1
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_1 1], scope: 0, id: 1),
          # 2
          ins(instruction: 'jump', inputs: %w[2], scope: 0, id: 2),
          # 3
          ins(instruction: 'print', inputs: ['"inside 1"'], scope: 1, id: 3),
          # 4
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 4),
          # 5
          ins(instruction: 'print', inputs: ['"inside 2"'], scope: 2, id: 5),
          # 6
          ins(instruction: 'jump', inputs: ['0'], scope: 2, id: 6)
        ]
      end

      let(:expected_output) do
        <<~RUST
          let CONDITIONAL_RESULT_1 = 1 == 2;
          if CONDITIONAL_RESULT_1 {
              log!("inside 1");
          }
          else {
              log!("inside 2");
          }
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when if elif else' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 2], assign: 'CONDITIONAL_RESULT_1', scope: 0, id: 0),
          # 1
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_1 1], scope: 0, id: 1),
          # 2
          ins(instruction: 'jump', inputs: %w[2], scope: 0, id: 2),
          # 3
          ins(instruction: 'print', inputs: ['"inside 1"'], scope: 1, id: 3),
          # 4
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 4),
          # 5
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 3], assign: 'CONDITIONAL_RESULT_5', scope: 2, id: 5),
          # 6
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_5 7], scope: 2, id: 6),
          # 7
          ins(instruction: 'jump', inputs: %w[8], scope: 2, id: 7),
          # 8
          ins(instruction: 'print', inputs: ['"inside 7"'], scope: 7, id: 8),
          # 9
          ins(instruction: 'jump', inputs: ['1'], scope: 7, id: 9),
          # 10
          ins(instruction: 'print', inputs: ['"inside 8"'], scope: 8, id: 10),
          # 11
          ins(instruction: 'jump', inputs: ['1'], scope: 8, id: 11),
          # 12
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 12)
        ]
      end

      let(:expected_output) do
        <<~RUST
          let CONDITIONAL_RESULT_1 = 1 == 2;
          if CONDITIONAL_RESULT_1 {
              log!("inside 1");
          }
          else {
              let CONDITIONAL_RESULT_5 = 1 == 3;
              if CONDITIONAL_RESULT_5 {
                  log!("inside 7");
              }
              else {
                  log!("inside 8");
              }
          }
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when if let' do
      let(:instructions) do
        [
          # 3
          ins(instruction: 'try_assign', inputs: ['letter', 'Some(i)'], assign: 'CONDITIONAL_JUMP_ASSIGNMENT_0',
              scope: 0, id: 3),
          # 5
          ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_0', 4], scope: 0, id: 5),
          # 9
          ins(instruction: 'jump', inputs: ['8'], scope: 0, id: 9),
          # 6
          ins(instruction: 'print', inputs: ['"Matched {:?}!"', 'i'], scope: 4, id: 6),
          # 7
          ins(instruction: 'jump', inputs: ['0'], scope: 4, id: 7),
          # 10
          ins(instruction: 'print', inputs: ['"Didn\'t match a number. Let\'s go with a letter!"'], scope: 8, id: 10),
          # 11
          ins(instruction: 'jump', inputs: ['0'], scope: 8, id: 11),
          # 15
          ins(instruction: 'try_assign', inputs: ['ok_foobar', 'Ok(foobar)'], assign: 'CONDITIONAL_JUMP_ASSIGNMENT_12',
              scope: 0, id: 15),
          # 17
          ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_12', 16], scope: 0, id: 17),
          # 20
          ins(instruction: 'return', inputs: ['foobar'], scope: 16, id: 20),
          # 21
          ins(instruction: 'jump', inputs: ['0'], scope: 16, id: 21),
          # 22
          ins(instruction: 'exit_with_message', inputs: ['"This is a panic!"'], scope: 0, id: 22)
        ]
      end

      let(:expected_output) do
        <<~RUST
          if let Some(i) = letter {
              log!("Matched {:?}!", i);
          }
          else {
              log!("Didn't match a number. Let's go with a letter!");
          }
          if let Ok(foobar) = ok_foobar {
              return foobar;
          }
          panic!("This is a panic!");
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when let else' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'try_assign', inputs: ['ok_count', 'Ok(count)'], assign: 'CONDITIONAL_JUMP_ASSIGNMENT_0',
              scope: 0, id: 0),
          # 1
          ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_0', 1], scope: 0, id: 1),
          # 2
          ins(instruction: 'jump', inputs: ['2'], scope: 0, id: 2),
          # 3
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 3),
          # 4
          ins(instruction: 'exit_with_message', inputs: ['"Can\'t parse integer: \'{count_str}\'"'], scope: 2, id: 4),
          # 6
          ins(instruction: 'instantiate_object', inputs: %w[Tuple count item], assign: 'Thing_to_return',
              scope: 0, id: 6),
          # 7
          ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 7)
        ]
      end

      let(:expected_output) do
        <<~RUST
          if let Ok(count) = ok_count {
          }
          else {
              panic!("Can't parse integer: '{count_str}'");
          }
          Thing_to_return = (count, item);
          return Thing_to_return;
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when nested ifs' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'jump', inputs: %w[true 1], scope: 0, id: 0),
          # 1
          ins(instruction: 'jump', inputs: ['y == 2', 2], scope: 1, id: 1),
          # 2
          ins(instruction: 'jump', inputs: ['3'], scope: 1, id: 2),
          # 3
          ins(instruction: 'print', inputs: ['"inside 2"'], scope: 2, id: 3),
          # 4
          ins(instruction: 'jump', inputs: ['1'], scope: 2, id: 4),
          # 5
          ins(instruction: 'print', inputs: ['"inside 3"'], scope: 3, id: 5),
          # 6
          ins(instruction: 'jump', inputs: ['1'], scope: 3, id: 6),
          # 7
          ins(instruction: 'print', inputs: ['"inside 1"'], scope: 1, id: 7),
          # 8
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 8),
          # 9
          ins(instruction: 'print', inputs: ['"the end"'], scope: 0, id: 9)
        ]
      end

      let(:expected_output) do
        <<~RUST
          if true {
              if y == 2 {
                  log!("inside 2");
              }
              else {
                  log!("inside 3");
              }
              log!("inside 1");
          }
          log!("the end");
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when match statement' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 2], assign: 'CONDITIONAL_RESULT_1', scope: 0, id: 0),
          # 1
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 3], assign: 'CONDITIONAL_RESULT_2', scope: 0, id: 1),
          # 2
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_1 1], scope: 0, id: 2),
          # 3
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_2 2], scope: 0, id: 3),
          # 4
          ins(instruction: 'jump', inputs: %w[3], scope: 0, id: 4),
          # 5
          ins(instruction: 'print', inputs: ['"inside 1"'], scope: 1, id: 5),
          # 6
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 6),
          # 7
          ins(instruction: 'print', inputs: ['"inside 2"'], scope: 2, id: 7),
          # 8
          ins(instruction: 'jump', inputs: ['0'], scope: 2, id: 8),
          # 9
          ins(instruction: 'print', inputs: ['"inside 3"'], scope: 3, id: 9),
          # 10
          ins(instruction: 'jump', inputs: ['0'], scope: 3, id: 10)
        ]
      end

      let(:expected_output) do
        <<~RUST
          let CONDITIONAL_RESULT_1 = 1 == 2;
          let CONDITIONAL_RESULT_2 = 1 == 3;
          if CONDITIONAL_RESULT_1 {
              log!("inside 1");
          }
          else if CONDITIONAL_RESULT_2 {
              log!("inside 2");
          }
          else {
              log!("inside 3");
          }
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when panic' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 2], assign: 'CONDITIONAL_RESULT_1', scope: 0, id: 0),
          # 1
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_1 1], scope: 0, id: 1),
          # 2
          ins(instruction: 'exit_with_message', inputs: ['"Oh no! We are inside 1!"'], scope: 1, id: 2)
        ]
      end

      let(:expected_output) do
        <<~RUST
          let CONDITIONAL_RESULT_1 = 1 == 2;
          if CONDITIONAL_RESULT_1 {
              panic!("Oh no! We are inside 1!");
          }
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when return if else' do
      let(:instructions) do
        [
          # 4
          ins(instruction: 'jump', inputs: %w[is_answer_to_life 3], scope: 0, id: 4),
          # 8
          ins(instruction: 'jump', inputs: ['7'], scope: 0, id: 8),
          # 5
          ins(instruction: 'assign', inputs: ['42'], assign: 'RETURN_VALUE_LABEL_0', scope: 3, id: 5),
          # 6
          ins(instruction: 'jump', inputs: ['0'], scope: 3, id: 6),
          # 9
          ins(instruction: 'assign', inputs: ['40'], assign: 'RETURN_VALUE_LABEL_0', scope: 7, id: 9),
          # 10
          ins(instruction: 'jump', inputs: ['0'], scope: 7, id: 10),
          # 11
          ins(instruction: 'return', inputs: ['RETURN_VALUE_LABEL_0'], scope: 0, id: 11)
        ]
      end

      let(:expected_output) do
        <<~RUST
          if is_answer_to_life {
              let mut RETURN_VALUE_LABEL_0 = 42;
          }
          else {
              let mut RETURN_VALUE_LABEL_0 = 40;
          }
          return RETURN_VALUE_LABEL_0;
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when break statement' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'evaluate', inputs: %w[equal_to 1 2], assign: 'CONDITIONAL_RESULT_1', scope: 0, id: 0),
          # 1
          ins(instruction: 'jump', inputs: %w[CONDITIONAL_RESULT_1 1], scope: 0, id: 1),
          # 2
          ins(instruction: 'break', inputs: [], scope: 1, id: 2),
          # 3
          ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 3)
        ]
      end

      let(:expected_output) do
        <<~RUST
          let CONDITIONAL_RESULT_1 = 1 == 2;
          if CONDITIONAL_RESULT_1 {
              break;
          }
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end
  end

  describe 'when for loop' do
    context 'when for loop with range iterator' do
      let(:instructions) do
        [
          # 1
          ins(instruction: 'assign', inputs: ['0'], assign: 'sum', scope: 0, id: 1),
          # 3
          ins(instruction: 'assign', inputs: ['v1.iter()'], assign: 'ITERATOR_1', scope: 0, id: 3),
          # 4
          ins(instruction: 'evaluate', inputs: %w[start ITERATOR_1], assign: 'i', scope: 0, id: 4),
          # 5
          ins(instruction: 'end_of_iteration_check', inputs: %w[i ITERATOR_1], assign: 'CHECK_CONDITION_ASSIGNMENT_2',
              scope: 0, id: 5),
          # 7
          ins(instruction: 'jump', inputs: %w[CHECK_CONDITION_ASSIGNMENT_2 6], scope: 0, id: 7),
          # 12
          ins(instruction: 'add', inputs: %w[sum i], assign: 'sum', scope: 6, id: 12),
          # 13
          ins(instruction: 'increment', inputs: %w[i ITERATOR_1], scope: 6, id: 13),
          # 14
          ins(instruction: 'goto', inputs: ['5'], scope: 6, id: 14),
          # 0
          ins(instruction: 'return', inputs: ['sum'], scope: 0, id: 0)
        ]
      end

      # TODO:
      # * track variables that have already been assign

      let(:expected_output) do
        <<~RUST
          let mut sum = 0;
          let mut ITERATOR_1 = v1.iter();
          let mut OPTION_i = ITERATOR_1.next();
          while let Some(i) = OPTION_i {
              sum = sum + i;
              OPTION_i = ITERATOR_1.next();
          }
          return sum;
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end

    context 'when for loop with non-range iterator' do
      let(:instructions) do
        [
          # 0
          ins(instruction: 'assign', inputs: ['1'], assign: 'RANGE_START_1', scope: 0, id: 0),
          # 1
          ins(instruction: 'assign', inputs: ['10'], assign: 'RANGE_END_2', scope: 0, id: 1),
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
      end

      let(:expected_output) do
        <<~RUST
          let mut RANGE_START_1 = 1;
          let mut RANGE_END_2 = 10;
          let mut range_thing = RANGE_START_1..RANGE_END_2;
          let mut ITERATOR_1 = range_thing;
          let mut OPTION_i = ITERATOR_1.next();
          while let Some(i) = OPTION_i {
              let mut sum = sum + i;
              OPTION_i = ITERATOR_1.next();
          }
          return sum;
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instructions).generate).to eq(expected_output)
      end
    end
  end

  describe 'when macro' do
    context 'when log!' do
      let(:instruction) do
        [
          ins(id: 0, instruction: 'print', inputs: ['"Some input is greater than 15"'], scope: 0)
        ]
      end

      let(:expected_output) do
        <<~RUST
          log!("Some input is greater than 15");
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instruction).generate).to eq(expected_output)
      end
    end

    context 'when panic!' do
      let(:instruction) do
        [
          ins(id: 0, instruction: 'exit_with_message', inputs: ['"Some input is greater than 15"'], scope: 0)
        ]
      end

      let(:expected_output) do
        <<~RUST
          panic!("Some input is greater than 15");
        RUST
      end

      it 'generates the correct Rust code' do
        expect(described_class.new(instruction).generate).to eq(expected_output)
      end
    end
  end

  describe 'when binary instruction' do
    context 'when add' do
      context 'when assign is a variable' do
        let(:instruction) do
          [
            ins(id: 0, instruction: 'add', inputs: %w[10 11], assign: 'result', scope: 0)
          ]
        end

        let(:expected_output) do
          <<~RUST
            let mut result = 10 + 11;
          RUST
        end

        it 'generates the correct Rust code' do
          expect(described_class.new(instruction).generate).to eq(expected_output)
        end
      end

      context 'when assign is a field' do
        let(:instruction) do
          [
            ins(id: 0, instruction: 'add', inputs: %w[10 11], assign: 'foo.bar', scope: 0)
          ]
        end

        let(:expected_output) do
          <<~RUST
            foo.bar = 10 + 11;
          RUST
        end

        it 'generates the correct Rust code' do
          expect(described_class.new(instruction).generate).to eq(expected_output)
        end
      end

      context 'when assign is a return value' do
        let(:instruction) do
          [
            ins(id: 0, instruction: 'add', inputs: %w[10 11], assign: 'Thing_to_return', scope: 0)
          ]
        end

        let(:expected_output) do
          <<~RUST
            Thing_to_return = 10 + 11;
          RUST
        end

        it 'generates the correct Rust code' do
          expect(described_class.new(instruction).generate).to eq(expected_output)
        end
      end

      context 'when result is ampersanded' do
        let(:instruction) do
          [
            ins(id: 0, instruction: 'add', inputs: %w[& 10 11], assign: 'result', scope: 0)
          ]
        end

        let(:expected_output) do
          <<~RUST
            let mut result = &(10 + 11);
          RUST
        end

        it 'generates the correct Rust code' do
          expect(described_class.new(instruction).generate).to eq(expected_output)
        end
      end

      # TODO: no way to differentiate between assign and first argument being ampersanded
      context 'when argument is ampersanded' do
        let(:instruction) do
          [
            ins(id: 0, instruction: 'add', inputs: %w[10 & 11], assign: 'result', scope: 0)
          ]
        end

        let(:expected_output) do
          <<~RUST
            let mut result = 10 + &11;
          RUST
        end

        it 'generates the correct Rust code' do
          expect(described_class.new(instruction).generate).to eq(expected_output)
        end
      end
    end
  end
end
