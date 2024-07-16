module SorobanRustBackend
  module Instruction
    # This class is responsible for generating Rust code for the AddAndAssign instruction.
    class Handler
      def initialize(instruction, metadata)
        @instruction = instruction
        @metadata = metadata

        format_assign
      end

      def format_assign
        return unless @instruction.assign&.include?('|||') && @instruction.assign.split('|||').size == 2

        var_name, type_name = @instruction.assign.split('|||')

        @instruction = DTRCore::Instruction.new(
          @instruction.instruction,
          @instruction.inputs,
          "#{var_name}: #{Common::TypeTranslator.translate_type(type_name)}",
          @instruction.scope,
          @instruction.id
        )
      end

      def self.handle(instruction, metadata)
        new(instruction, metadata).handle
      end
    end
  end
end
