module SorobanRustBackend
  module Instruction
    class EndOfIterationCheck < Handler
      def handle
        'if !iteration_finished {'
      end
    end
  end
end
