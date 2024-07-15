module SorobanRustBackend
  class FunctionHandler
    def initialize(function, is_helper)
      @function = function
      @is_helper = is_helper
    end

    def self.generate(function, is_helper)
      new(function, is_helper).generate
    end

    def generate
      content = ''

      content = "\n#{@is_helper ? '' : '    '}pub fn #{@function.name}(#{generate_function_args}) "
      content += generate_function_output

      content += " {\n"
      if @function.output
        content += "#{@is_helper ? '    ' : '        '}let Thing_to_return: #{Common::TypeTranslator.translate_type(@function.output)};\n"
      end
      content += generate_instructions_for_blocks(@function.instructions)

      content += "\n#{@is_helper ? '' : '    '}}\n"

      content
    end

    private

    def generate_function_output
      return '' if @function.output.nil?

      "-> #{Common::TypeTranslator.translate_type(@function.output)}"
    end

    def generate_function_args
      all_inputs = [] + @function.inputs

      all_inputs.map { |x| "#{x[:name]}: #{Common::TypeTranslator.translate_type(x[:type_name])}" }.join(', ')
    end

    def generate_instructions_for_blocks(instructions)
      CodeGenerator.new(instructions, base_indentation: @is_helper ? 1 : 2).generate
    end
  end
end
