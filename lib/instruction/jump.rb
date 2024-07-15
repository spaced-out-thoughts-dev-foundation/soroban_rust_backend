# frozen_string_literal: true

module SorobanRustBackend
  module Instruction
    # This class handles the jump instruction.
    class Jump < Handler
      def handle
        last_instruction_is_else_if = @instruction.inputs[@instruction.inputs.size - 1] == 'ELSE_IF_BRANCH'
        last_instruction_is_while_loop = @instruction.inputs[@instruction.inputs.size - 1] == 'WHILE_LOOP'

        if @instruction.inputs.size == 1
          handle_unconditional_jump
        elsif @instruction.inputs.size == 2
          last_instruction_is_else_if ? handle_unconditional_jump : handle_conditional_jump
        elsif @instruction.inputs.size == 3 && last_instruction_is_else_if
          handle_conditional_else_if_jump
        elsif @instruction.inputs.size == 4 && last_instruction_is_while_loop
          handle_while_loop
        else
          raise 'Invalid jump instruction. Received too many inputs: ' + @instruction.inputs.size.to_s
        end
      end

      private

      def handle_conditional_jump
        "if #{@instruction.inputs[0]} {"
      end

      def handle_while_loop
        "while let Some(#{@instruction.inputs[0]}) = OPTION_#{@instruction.inputs[0]} {"
      end

      def handle_conditional_else_if_jump
        "else if #{@instruction.inputs[0]} {"
      end

      def handle_unconditional_jump
        if @instruction.scope.to_i < @instruction.inputs[0].to_i
          'else {'
        else
          '}'
        end
      end
    end
  end
end
