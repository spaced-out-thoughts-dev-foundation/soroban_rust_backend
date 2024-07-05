# frozen_string_literal: true

module DTRToRust
  module Instruction
    # This class handles the exit_with_message instruction.
    class ExitWithMessage < Handler
      def handle
        form_rust_string("panic!(#{inputs_to_rust_string(@instruction.inputs)});")
      end

      private

      def inputs_to_rust_string(inputs)
        inputs.map { |input| Common::ReferenceAppender.call(input, function_inputs: @function_inputs) }.join(', ')
      end
    end
  end
end
