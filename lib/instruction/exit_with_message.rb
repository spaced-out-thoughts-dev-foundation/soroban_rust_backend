module SorobanRustBackend
  module Instruction
    # This class handles the exit_with_message instruction.
    class ExitWithMessage < Handler
      def handle
        "panic!(#{inputs_to_rust_string(@instruction.inputs)});"
      end

      private

      def inputs_to_rust_string(inputs)
        # inputs.map { |input| Common::ReferenceAppender.call(input, function_inputs: @function_inputs) }.join(', ')
        inputs.map { |input| input }.join(', ')
      end
    end
  end
end
