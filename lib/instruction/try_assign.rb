module SorobanRustBackend
  module Instruction
    # This class handles the goto instruction.
    class TryAssign < Handler
      def handle
        "let #{@instruction.inputs[0]} = #{@instruction.inputs[1]}.try_into();"
      end
    end
  end
end
