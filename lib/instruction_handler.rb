module SorobanRustBackend
  # This class is responsible for generating Rust code for a single instruction.
  class InstructionHandler
    def initialize(instruction, metadata)
      @instruction = instruction
      @metadata = metadata
    end

    def generate_rust
      unless EXPRESSION_FOOBAR.key?(@instruction.instruction.strip)
        raise "Unknown instruction type: #{@instruction.instruction}"
      end

      EXPRESSION_FOOBAR[@instruction.instruction.strip].send(:handle, @instruction, @metadata)
    end

    private

    EXPRESSION_FOOBAR = {
      'assign' => Instruction::Assign,
      'break' => Instruction::Break,
      'jump' => Instruction::Jump,
      'exit_with_message' => Instruction::ExitWithMessage,
      'and' => Instruction::And,
      'or' => Instruction::Or,
      'add' => Instruction::Add,
      'subtract' => Instruction::Subtract,
      'multiply' => Instruction::Multiply,
      'divide' => Instruction::Divide,
      'instantiate_object' => Instruction::InstantiateObject,
      'print' => Instruction::Print,
      'return' => Instruction::Return,
      'evaluate' => Instruction::Evaluate,
      'field' => Instruction::Field,
      'end_of_iteration_check' => Instruction::EndOfIterationCheck,
      'increment' => Instruction::Increment,
      'try_assign' => Instruction::TryAssign
    }.freeze

    def handle_empty_instruction
      ''
    end
    attr_reader :instruction
  end
end
