module SorobanRustBackend
  module Instruction
    # This class handles the assign instruction.
    class Assign < Handler
      def handle
        if @instruction.assign.include?('.') || @instruction.assign == 'Thing_to_return'
          "#{@instruction.assign} = #{@instruction.inputs[0]};"
        else
          "let mut #{@instruction.assign} = #{@instruction.inputs[0]};"
        end
      end
    end
  end
end
