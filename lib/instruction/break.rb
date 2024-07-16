module SorobanRustBackend
  module Instruction
    # This class handles the add instruction.
    class Break < Handler
      def handle
        'break;'
      end
    end
  end
end
