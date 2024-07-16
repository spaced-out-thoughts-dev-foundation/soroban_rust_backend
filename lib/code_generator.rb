module SorobanRustBackend
  class CodeGenerator
    def initialize(instructions, base_indentation: 0, user_defined_types: [], function_names: [])
      @instructions = instructions
      @base_indentation = base_indentation
      @user_defined_types = user_defined_types
      @function_names = function_names

      silviculturist = SorobanRustBackend::Silviculturist.new(instructions, base_indentation:)
      silviculturist.make_forrest

      @forrest = silviculturist.forrest
    end

    def generate
      return_string = ''

      @forrest
        .code_generator_traverse do |y|
        y = y.compact

        og_instruction = y[0]
        instruction = handle_metadata(y[0], y[2])
        indentation = og_instruction.instruction == 'goto' ? y[2][:return_scope] + @base_indentation : y[1]

        return_string << "#{'    ' * indentation}#{InstructionHandler.new(instruction, y[2]).generate_rust}\n"
      end

      return_string
    end

    def handle_metadata(instruction, metadata)
      if instruction.instruction == 'goto'
        DTRCore::Instruction.new(
          'jump',
          [metadata[:return_scope]],
          instruction.assign,
          instruction.scope,
          instruction.id
        )
      elsif match_statement?(instruction, metadata)
        DTRCore::Instruction.new(
          'jump',
          instruction.inputs + ['ELSE_IF_BRANCH'],
          instruction.assign,
          instruction.scope,
          instruction.id
        )
      elsif if_let?(instruction, metadata)
        let_statement = "let #{metadata[:try_assign][:lhs]} = #{metadata[:try_assign][:rhs]}"
        DTRCore::Instruction.new(
          'jump',
          [let_statement, instruction.inputs[1]],
          instruction.assign,
          instruction.scope,
          instruction.id
        )
      elsif while_loop?(instruction, metadata)
        operator_variable = "#{metadata[:end_of_iteration_check][:lhs]}"
        iterator_variable = "#{metadata[:end_of_iteration_check][:rhs]}"

        DTRCore::Instruction.new(
          'jump',
          [operator_variable, iterator_variable, instruction.inputs[1], 'WHILE_LOOP'],
          instruction.assign,
          instruction.scope,
          instruction.id
        )
      elsif udt?(instruction)
        inputs = instruction.inputs
        udt_found = nil

        @user_defined_types.each do |udt|
          fixed_udt_name = udt_name_fix(udt)

          if fixed_udt_name == inputs[1]
            udt_found = inputs.push(udt)
            break
          end
        end

        raise "Unable to instantiate unrecognized UDT: #{inputs[1]}" if udt_found.nil?

        DTRCore::Instruction.new(
          'instantiate_object',
          inputs,
          instruction.assign,
          instruction.scope,
          instruction.id
        )
      elsif instruction.instruction == 'evaluate'
        method_name = instruction.inputs[0]

        method_name = "Self::#{method_name}" if @function_names.include?(method_name)

        DTRCore::Instruction.new(
          'evaluate',
          [method_name] + instruction.inputs[1..],
          instruction.assign,
          instruction.scope,
          instruction.id
        )
      else
        instruction
      end
    end

    def udt_name_fix(udt)
      if udt.name.end_with?('_STRUCT') || udt.name.end_with?('_ENUM')
        udt.name.split('_')[0..-2].join('_')
      else
        udt.name
      end
    end

    def match_statement?(instruction, metadata)
      metadata[:last_node_was_conditional_jump] && instruction.instruction == 'jump' && metadata[:parent_scope] && metadata[:parent_scope] == instruction.scope
    end

    def if_let?(instruction, metadata)
      instruction.instruction == 'jump' &&
        metadata[:try_assign] &&
        metadata[:try_assign][:assign] == instruction.inputs[0] &&
        metadata[:parent_scope] == instruction.scope
    end

    def while_loop?(instruction, metadata)
      instruction.instruction == 'jump' &&
        metadata[:end_of_iteration_check] &&
        metadata[:end_of_iteration_check][:assign] == instruction.inputs[0] &&
        metadata[:parent_scope] == instruction.scope
    end

    def udt?(instruction)
      instruction.instruction == 'instantiate_object' && instruction.inputs[0] == 'UDT'
    end
  end
end
