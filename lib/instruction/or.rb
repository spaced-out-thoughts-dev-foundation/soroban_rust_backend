module SorobanRustBackend
  module Instruction
    # This class handles the or instruction.
    class Or < Handler
      def handle
        inputs = @instruction.inputs
        assignment = @instruction.assign

        assignment_rust = "let #{assignment} = "
        body_rust = "#{inputs[0]} || #{inputs[1]};"
        "#{assignment.nil? ? '' : assignment_rust}#{body_rust}"
      end
    end
  end
end
