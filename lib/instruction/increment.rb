module SorobanRustBackend
  module Instruction
    class Increment < Handler
      def handle
        # assumes non-range iterator
        "OPTION_#{@instruction.inputs[0]} = #{@instruction.inputs[1]}.next();"
      end
    end
  end
end
