module SorobanRustBackend
  class ContractHandler
    def initialize(contract)
      @dtr_contract = contract
    end

    def self.generate(contract)
      new(contract).generate
    end

    def generate
      generate_contract
    end

    private

    attr_reader :dtr_contract

    def generate_contract
      @content = ''

      @content += NonTranslatables::Handler.generate(dtr_contract.non_translatables) if dtr_contract.non_translatables

      if dtr_contract.user_defined_types
        dtr_contract.user_defined_types.each do |user_defined_type|
          @content += SorobanRustBackend::UserDefinedTypesHandler.generate(user_defined_type)
        end
      end
      @content += ContractState::Handler.generate(dtr_contract.state) if dtr_contract.state
      generate_contract_name
      generate_interface if dtr_contract.interface
      generate_helpers if dtr_contract.helpers

      generate_contract_header

      @content
    end

    def generate_interface
      @content += "#[contractimpl]\nimpl #{dtr_contract.name} {#{generate_functions_each(dtr_contract.interface,
                                                                                         false)}}\n"
    end

    def generate_helpers
      @content += "#{generate_functions_each(dtr_contract.helpers, true)}\n"
    end

    def generate_functions_each(functions, is_helper)
      # function_names = functions&.map(&:name)

      functions&.map do |function|
        FunctionHandler.generate(function, is_helper)
      end&.join("\n")
    end

    def generate_contract_header
      imports_super_set = %w[
        Address
        BytesN
        contract
        contractimpl
        contracttype
        contracterror
        symbol_short
        vec
        Env
        String
        Symbol
        Vec
        Val
        log
        token
      ]

      used_imports = []

      @content.split.each do |word|
        imports_super_set.each do |import|
          used_imports << import if word.include?(import)
        end
      end

      used_imports.uniq!

      # TODO: unsure how to check this one
      used_imports << 'auth::Context'
      used_imports << 'IntoVal'
      used_imports << 'unwrap::UnwrapOptimized'

      # TODO: don't hardcode imports
      @content = "#![no_std]\nuse soroban_sdk::{#{used_imports.join(', ')}};\n\n" + @content
    end

    def generate_contract_name
      @content += "#[contract]\npub struct #{dtr_contract.name};\n\n"
    end
  end
end
