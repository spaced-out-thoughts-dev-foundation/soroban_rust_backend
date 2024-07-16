module SorobanRustBackend
  module ContractState
    class Handler
      def initialize(state)
        @state = state
      end

      def self.generate(state)
        new(state).generate
      end

      def generate
        generate_state
      end

      private

      def generate_state
        content = ''

        @state.each do |state_value|
          if state_value.type == 'Symbol'
            content += "const #{state_value.name}: Symbol = symbol_short!(#{state_value.initial_value});\n"
          # TODO: This is a hack. We need to find a better way to handle this and prove its correctness.
          elsif state_value.type == 'String'
            content += "const #{state_value.name}: Symbol = symbol_short!(#{state_value.initial_value});\n"
          else
            content += "const #{state_value.name}: #{Common::TypeTranslator.translate_type(state_value.type)} = #{state_value.initial_value};\n"
          end
        end

        content
      end
    end
  end
end
