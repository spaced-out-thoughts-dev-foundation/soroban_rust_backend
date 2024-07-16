require 'spec_helper'

RSpec.describe SorobanRustBackend::Silviculturist do
  let(:one_plus_two_is_x) do
    ins(
      instruction: 'evaluate',
      inputs: %w[add 1 2],
      assign: 'x',
      scope: 0,
      id: 0
    )
  end

  let(:x_minus_three_is_y) do
    ins(
      instruction: 'evaluate',
      inputs: %w[sub x 3],
      assign: 'y',
      scope: 0,
      id: 1
    )
  end

  let(:jump_to_1_if_y_is_0) do
    ins(
      instruction: 'jump',
      inputs: ['y == 0', 1],
      scope: 0,
      id: 2
    )
  end

  let(:otherwise_jump_to_2) do
    ins(
      instruction: 'jump',
      inputs: ['2'],
      scope: 0,
      id: 3
    )
  end

  let(:print_inside_1) do
    ins(
      instruction: 'print',
      inputs: ['inside 1'],
      scope: 1,
      id: 4
    )
  end

  let(:jump_back_to_0_from_1) do
    ins(
      instruction: 'jump',
      inputs: ['0'],
      scope: 1,
      id: 5
    )
  end

  let(:print_inside_2) do
    ins(
      instruction: 'print',
      inputs: ['inside 2'],
      scope: 2,
      id: 6
    )
  end

  let(:jump_back_to_0_from_2) do
    ins(
      instruction: 'jump',
      inputs: ['0'],
      scope: 2,
      id: 7
    )
  end

  let(:print_the_end) do
    ins(
      instruction: 'print',
      inputs: ['the end'],
      scope: 0,
      id: 8
    )
  end

  let(:unconditional_jump_to_3) do
    ins(
      instruction: 'jump',
      inputs: ['3'],
      scope: 0,
      id: 9
    )
  end

  let(:print_inside_3) do
    ins(
      instruction: 'print',
      inputs: ['inside 3'],
      scope: 3,
      id: 10
    )
  end

  let(:jump_back_to_0_from_3) do
    ins(
      instruction: 'jump',
      inputs: ['0'],
      scope: 3,
      id: 11
    )
  end

  let(:print_now_the_actual_end) do
    ins(
      instruction: 'print',
      inputs: ['now the actual end'],
      scope: 0,
      id: 12
    )
  end

  let(:check_end_of_iteration) do
    ins(
      instruction: 'end_of_iteration_check',
      inputs: ['true'],
      assign: 'CHECK_CONDITION_ASSIGNMENT_1',
      scope: 0,
      id: 13
    )
  end

  let(:conditional_jump_if_not_end_of_iteration) do
    ins(
      instruction: 'jump',
      inputs: ['CHECK_CONDITION_ASSIGNMENT_1 == false', 1],
      scope: 0,
      id: 14
    )
  end

  let(:goto_1) do
    ins(
      instruction: 'goto',
      inputs: ['13'],
      scope: 1,
      id: 15
    )
  end

  context 'when no instructions' do
    it 'plants no trees and thus there should be no forrest' do
      silviculturist = described_class.new([])
      silviculturist.make_forrest
      expect(silviculturist.forrest.size).to eq(0)
      expect(silviculturist.forrest.traverse.size).to eq(0)
    end
  end

  context 'when two instructions with no branching' do
    let(:instructions) do
      [
        # 0
        one_plus_two_is_x,
        # 1
        x_minus_three_is_y
      ]
    end

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(1)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(2)
    end
  end

  context 'when nine instructions with branching' do
    let(:instructions) do
      [
        # 0
        one_plus_two_is_x,
        # 1
        x_minus_three_is_y,
        # 2
        jump_to_1_if_y_is_0,
        # 3
        otherwise_jump_to_2,
        # 4
        print_inside_1,
        # 5
        jump_back_to_0_from_1,
        # 6
        print_inside_2,
        # 7
        jump_back_to_0_from_2,
        # 8
        print_the_end
      ]
    end

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(2)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(9)
      expect(silviculturist.forrest.traverse_to_ids).to eq([
                                                             [0, 1, 2, 4, 5, 3, 6, 7],
                                                             [8]
                                                           ])
    end
  end

  context 'when thirteen instructions with branching' do
    let(:instructions) do
      [
        # 0
        one_plus_two_is_x,
        # 1
        x_minus_three_is_y,
        # 2
        jump_to_1_if_y_is_0,
        # 3
        otherwise_jump_to_2,
        # 4
        print_inside_1,
        # 5
        jump_back_to_0_from_1,
        # 6
        print_inside_2,
        # 7
        jump_back_to_0_from_2,
        # 8
        print_the_end,
        # 9
        unconditional_jump_to_3,
        # 10
        print_inside_3,
        # 11
        jump_back_to_0_from_3,
        # 12
        print_now_the_actual_end
      ]
    end

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(3)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(13)
      expect(silviculturist.forrest.traverse_to_ids).to eq([
                                                             [0, 1, 2, 4, 5, 3, 6, 7],
                                                             [8, 9, 10, 11],
                                                             [12]
                                                           ])
    end
  end

  context 'when multiple instructions with a goto' do
    let(:instructions) do
      [
        # 0 - 0
        one_plus_two_is_x,
        # 1 - 0
        x_minus_three_is_y,
        # 13 - 0
        check_end_of_iteration,
        # 14 - 1 | 0
        conditional_jump_if_not_end_of_iteration,
        # 15 - 1
        goto_1,
        # 8 - 0
        print_the_end
      ]
    end

    it 'plants three trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(1)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(5)
      expect(silviculturist.forrest.traverse_to_ids).to eq([[0, 1, 14, 15, 8]])
    end
  end

  context 'when if let statement' do
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
        ins(instruction: 'print', inputs: ['Matched {:?}!', 'i'], scope: 4, id: 6),
        # 7
        ins(instruction: 'jump', inputs: ['0'], scope: 4, id: 7),
        # 10
        ins(instruction: 'print', inputs: ["Didn't match a number. Let's go with a letter!"], scope: 8, id: 10),
        # 11
        ins(instruction: 'jump', inputs: ['0'], scope: 8, id: 11),
        # 15
        ins(instruction: 'try_assign', inputs: ['ok_foobar', 'Ok(foobar)'], assign: 'CONDITIONAL_JUMP_ASSIGNMENT_12',
            scope: 0, id: 15),
        # 17
        ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_12', 16], scope: 0, id: 17),
        # 20
        ins(instruction: 'return', inputs: ['foobar'], scope: 16, id: 20),
        # 22
        ins(instruction: 'exit_with_message', inputs: ['This is a panic!'], scope: 0, id: 22)
      ]
    end

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(2)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(9)
      expect(silviculturist.forrest.traverse_to_ids).to eq([[5, 6, 7, 9, 10, 11], [17, 20, 22]])
    end
  end

  context 'when let else statement' do
    let(:instructions) do
      [
        # 4
        ins(instruction: 'evaluate', inputs: ['s.split', ' '], assign: 'it', scope: 0, id: 4),
        # 9
        ins(instruction: 'evaluate', inputs: ['it.next'], assign: 'TUPLE_ARG_1_0', scope: 0, id: 9),
        # 12
        ins(instruction: 'evaluate', inputs: ['it.next'], assign: 'TUPLE_ARG_2_0', scope: 0, id: 12),
        # 13
        ins(instruction: 'instantiate_object', inputs: %w[Tuple TUPLE_ARG_1_0 TUPLE_ARG_2_0],
            assign: 'TRY_ASSIGN_RESULT_5', scope: 0, id: 13),
        # 15
        ins(instruction: 'evaluate', inputs: ['try_assign', '(Some(count_str) Some(item))', 'TRY_ASSIGN_RESULT_5'],
            assign: 'TRY_ASSIGN_RESULT_CONDITIONAL_6', scope: 0, id: 15),
        # 17
        ins(instruction: 'jump', inputs: ['TRY_ASSIGN_RESULT_CONDITIONAL_6', 16], scope: 0, id: 17),
        # 19
        ins(instruction: 'jump', inputs: ['18'], scope: 0, id: 19),
        # 20
        ins(instruction: 'jump', inputs: ['0'], scope: 16, id: 20),
        # 21
        ins(instruction: 'exit_with_message', inputs: ["Can't segment count item pair: '{s}'"], scope: 18, id: 21),
        # 29
        ins(instruction: 'evaluate', inputs: ['u64::from_str', 'count_str'], assign: 'TRY_ASSIGN_RESULT_23', scope: 0,
            id: 29),
        # 30
        ins(instruction: 'evaluate', inputs: ['try_assign', 'Ok(count)', 'TRY_ASSIGN_RESULT_23'],
            assign: 'TRY_ASSIGN_RESULT_CONDITIONAL_24', scope: 0, id: 30),
        # 32
        ins(instruction: 'jump', inputs: ['TRY_ASSIGN_RESULT_CONDITIONAL_24', 31], scope: 0, id: 32),
        # 34
        ins(instruction: 'jump', inputs: ['33'], scope: 0, id: 34),
        # 35
        ins(instruction: 'jump', inputs: ['0'], scope: 31, id: 35),
        # 36
        ins(instruction: 'exit_with_message', inputs: ["Can't parse integer: '{count_str}'"], scope: 33, id: 36),
        # 40
        ins(instruction: 'instantiate_object', inputs: %w[Tuple count item], assign: 'Thing_to_return', scope: 0,
            id: 40),
        # 0
        ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 0)
      ]
    end

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(3)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(17)
      expect(silviculturist.forrest.traverse_to_ids).to eq([[4, 9, 12, 13, 15, 17, 20, 19, 21], [29, 30, 32, 35, 34, 36],
                                                            [40, 0]])
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

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(2)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(7)
      expect(silviculturist.forrest.traverse_to_ids).to eq([[4, 5, 6, 8, 9, 10], [11]])
    end
  end

  context 'when match statement' do
    let(:instructions) { match_statement }

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(1)
      expect(silviculturist.forrest.traverse.flatten.size).to eq(10)
      expect(silviculturist.forrest.traverse_to_ids).to eq([[3, 4, 7, 8, 5, 9, 10, 6, 11, 12]])
    end
  end

  context 'when simple nested loop' do
    let(:instructions) do
      [
        # 0
        ins(instruction: 'jump', inputs: %w[1], scope: 0, id: 0),
        # 1
        ins(instruction: 'jump', inputs: %w[y 2], scope: 1, id: 1),
        # 2
        ins(instruction: 'jump', inputs: ['3'], scope: 1, id: 2),
        # 3
        ins(instruction: 'print', inputs: ['inside 2'], scope: 2, id: 3),
        # 4
        ins(instruction: 'jump', inputs: ['1'], scope: 2, id: 4),
        # 5
        ins(instruction: 'print', inputs: ['inside 3'], scope: 3, id: 5),
        # 6
        ins(instruction: 'jump', inputs: ['1'], scope: 3, id: 6),
        # 7
        ins(instruction: 'print', inputs: ['inside 1'], scope: 1, id: 7),
        # 8
        ins(instruction: 'jump', inputs: ['0'], scope: 1, id: 8),
        # 9
        ins(instruction: 'print', inputs: ['the end'], scope: 0, id: 9)
      ]
    end

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(2)
      expect(silviculturist.forrest.traverse_to_ids.flatten.size).to eq(10)
      expect(silviculturist.forrest.traverse_to_ids).to eq([[0, 1, 3, 4, 7, 8, 2, 5, 6], [9]])

      expect(silviculturist.forrest.all_paths_to(8)).to eq([
                                                             [0, 1, 3, 4, 7, 8],
                                                             [0, 1, 2, 5, 6, 7, 8]
                                                           ])

      expect(silviculturist.forrest.all_paths_to(9)).to eq([[9]])

      expect(silviculturist.forrest.all_paths_to(3)).to eq([
                                                             [0, 1, 3]
                                                           ])

      expect(silviculturist.forrest.all_paths_to(11)).to eq([])
    end
  end

  context 'when complex nested if statement' do
    let(:instructions) { complex_nested_if_statement }

    it 'plants trees' do
      silviculturist = described_class.new(instructions)
      silviculturist.make_forrest

      expect(silviculturist.forrest.size).to eq(1)
      expect(silviculturist.forrest.traverse_to_ids.flatten.size).to eq(21)
      expect(silviculturist.forrest.traverse_to_ids).to eq([
                                                             [5, 7, 13, 15, 16, 21, 27, 29, 30, 31, 38, 40, 41, 42, 47,
                                                              44, 45, 46, 49, 54, 0]
                                                           ])
    end
  end
end
