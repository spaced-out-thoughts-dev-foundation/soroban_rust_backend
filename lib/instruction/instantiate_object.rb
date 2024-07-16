module SorobanRustBackend
  module Instruction
    # This class is responsible for generating Rust code for the LogString instruction.
    class InstantiateObject < Handler
      def handle
        @ref_preface = false
        if @instruction.inputs[0] == '&'
          @ref_preface = true
          @instruction.inputs.shift
        end

        case @instruction.inputs[0]
        when 'List'
          handle_list
        when 'UDT'
          handle_udt

        when 'Tuple'
          if @instruction.assign.include?('.') || @instruction.assign == 'Thing_to_return'
            "#{@instruction.assign} = #{@ref_preface ? '&' : ''}(#{normalish_inputs});"
          else
            "let mut #{@instruction.assign} = #{@ref_preface ? '&' : ''}(#{normalish_inputs});"
          end
        when 'Range'
          if @instruction.assign.include?('.') || @instruction.assign == 'Thing_to_return'
            "#{@instruction.assign} = #{@ref_preface ? '&' : ''}#{range_inputs};"
          else
            "let mut #{@instruction.assign} = #{@ref_preface ? '&' : ''}#{range_inputs};"
          end
        else
          raise "Unknown object type: #{@instruction.inputs[0]}"
        end
      end

      private

      def handle_list
        if @instruction.assign.include?('.') || @instruction.assign == 'Thing_to_return'
          "#{@instruction.assign} = #{@ref_preface ? '&' : ''}vec![#{normalish_inputs}];"
        else
          "let mut #{@instruction.assign} = #{@ref_preface ? '&' : ''}vec![#{normalish_inputs}];"
        end
      end

      def range_inputs
        @instruction.inputs[1..].map do |x|
          foobar(x)
        end.join('..')
      end

      def normalish_inputs
        @instruction.inputs[1..].map do |x|
          foobar(x)
        end.join(', ')
      end

      def udt_name_fix(udt)
        if udt.name.end_with?('_STRUCT') || udt.name.end_with?('_ENUM')
          udt.name.split('_')[0..-2].join('_')
        else
          udt.name
        end
      end

      def handle_udt
        udt_found = @instruction.inputs[@instruction.inputs.size - 1]

        inputs_sans_udt = @instruction.inputs[..-2][2..]
        assignment = "let mut #{@instruction.assign} = "
        udt = "#{@ref_preface ? '&' : ''}#{@instruction.inputs[1]}{"
        inputs = inputs_to_rust_string(inputs_sans_udt, udt_found.attributes.map do |x|
                                                          x[:name]
                                                        end)
        end_ = '};'
        "#{assignment}#{udt}#{inputs}#{end_}"
      end

      def inputs_to_rust_string(inputs, udt_type_names)
        inputs_to_return = []
        inputs.each_with_index do |input, index|
          inputs_to_return << handle_input(input, udt_type_names[index])
        end

        inputs_to_return.join(', ')
      end

      def foobar(input)
        decorated_input = Common::InputInterpreter.interpret(input)

        if decorated_input[:type] == 'string'
          "String::from_str(&env, #{input})"
        elsif decorated_input[:needs_reference] && input == 'env'
          "&#{input}"
        else
          input
        end
      end

      def handle_input(input, udt_type_name)
        value = foobar(input)

        "#{udt_type_name}: #{value}"
      end
    end
  end
end
