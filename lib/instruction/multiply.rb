module SorobanRustBackend
  module Instruction
    # This class handles the add instruction.
    class Multiply < BinaryInstruction
      def initialize(instruction, metadata)
        super('&', instruction, metadata)
      end
    end
  end
end
