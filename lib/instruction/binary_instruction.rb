module SorobanRustBackend
  module Instruction
    # This class handles the add instruction.
    class BinaryInstruction < Handler
      def initialize(operation, instruction, metadata)
        @operation = operation

        super(instruction, metadata)
      end

      def handle
        starts_with_ref = @instruction.inputs[0] == '&'
        if starts_with_ref
          @instruction = DTRCore::Instruction.new(
            @instruction.instruction,
            @instruction.inputs[1..],
            @instruction.assign,
            @instruction.scope,
            @instruction.id
          )
        end

        modded_inputs = []

        last_was_ref = false
        @instruction.inputs.each do |input|
          if last_was_ref
            modded_inputs << "&#{input}"
            last_was_ref = false
          elsif input == '&'
            last_was_ref = true
          else
            modded_inputs << input
          end
        end

        @instruction = DTRCore::Instruction.new(
          @instruction.instruction,
          modded_inputs,
          @instruction.assign,
          @instruction.scope,
          @instruction.id
        )

        if @metadata[:symbol_table].include?(@instruction.assign) || @instruction.assign.include?('.') || @instruction.assign == 'Thing_to_return'
          "#{@instruction.assign} = #{starts_with_ref ? '&(' : ''}#{@instruction.inputs[0]} #{@operation} #{@instruction.inputs[1]}#{starts_with_ref ? ')' : ''};"
        else
          "let mut #{@instruction.assign} = #{starts_with_ref ? '&(' : ''}#{@instruction.inputs[0]} #{@operation} #{@instruction.inputs[1]}#{starts_with_ref ? ')' : ''};"
        end
      end
    end
  end
end
