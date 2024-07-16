module SorobanRustBackend
  module Instruction
    # This class handles the add instruction.
    class BinaryInstruction < Handler
      def initialize(operation, instruction, metadata)
        @operation = operation

        super(instruction, metadata)
      end

      def handle
        if @metadata[:symbol_table].include?(@instruction.assign) || @instruction.assign.include?('.') || @instruction.assign == 'Thing_to_return'
          "#{@instruction.assign} = #{@instruction.inputs[0]} #{@operation} #{@instruction.inputs[1]};"
        else
          "let mut #{@instruction.assign} = #{@instruction.inputs[0]} #{@operation} #{@instruction.inputs[1]};"
        end
      end
    end
  end
end
