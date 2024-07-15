module SorobanRustBackend
  module NonTranslatables
    class Handler
      def initialize(non_translatables)
        @non_translatables = non_translatables
      end

      def self.generate(non_translatables)
        new(non_translatables).generate
      end

      def generate
        generate_non_translatables
      end

      private

      def generate_non_translatables
        @non_translatables
      end
    end
  end
end
