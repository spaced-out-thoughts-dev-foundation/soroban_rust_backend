# frozen_string_literal: true

module SorobanRustBackend
  module Instruction
    # This class handles the add instruction.
    class Divide < BinaryInstruction
      def initialize(instruction, metadata)
        super('/', instruction, metadata)
      end
    end
  end
end
