require 'dtr_core'

# This is the main module for the DTR to Rust gem.
module SorobanRustBackend
  autoload :LCPBT_Forrest, 'lcpbt_forrest'
  autoload :LeftChildPreferentialBinaryTree, 'left_child_preferential_binary_tree'
  autoload :Silviculturist, 'silviculturist'
  autoload :CodeGenerator, 'code_generator'
  autoload :InstructionHandler, 'instruction_handler'
  autoload :UserDefinedTypesHandler, 'user_defined_types_handler'
  autoload :FunctionHandler, 'function_handler'
  autoload :ContractHandler, 'contract_handler'

  # This module contains all the classes that handle the different types of instructions.
  module Instruction
    autoload :Evaluate, 'instruction/evaluate'
    autoload :Field, 'instruction/field'
    autoload :Handler, 'instruction/handler'
    autoload :Print, 'instruction/print'
    autoload :Return, 'instruction/return'
    autoload :InstantiateObject, 'instruction/instantiate_object'
    autoload :Add, 'instruction/add'
    autoload :Subtract, 'instruction/subtract'
    autoload :Multiply, 'instruction/multiply'
    autoload :Divide, 'instruction/divide'
    autoload :Assign, 'instruction/assign'
    autoload :Jump, 'instruction/jump'
    autoload :ExitWithMessage, 'instruction/exit_with_message'
    autoload :And, 'instruction/and'
    autoload :Or, 'instruction/or'
    autoload :EndOfIterationCheck, 'instruction/end_of_iteration_check'
    autoload :Increment, 'instruction/increment'
    autoload :TryAssign, 'instruction/try_assign'
    autoload :Break, 'instruction/break'
    autoload :BinaryInstruction, 'instruction/binary_instruction'
  end

  module Common
    autoload :TypeTranslator, 'common/type_translator'
    autoload :InputInterpreter, 'common/input_interpreter'
  end

  module NonTranslatables
    autoload :Handler, 'non_translatables/handler'
  end

  module ContractState
    autoload :Handler, 'contract_state/handler'
  end
end

def silence_streams
  original_stdout = $stdout
  original_stderr = $stderr
  $stdout = File.new('/dev/null', 'w')
  $stderr = File.new('/dev/null', 'w')
  yield
ensure
  $stdout = original_stdout
  $stderr = original_stderr
end

if __FILE__ == $PROGRAM_NAME
  input = ARGV[0]

  if input == 'version'
    gemspec_path = 'dtr_to_rust.gemspec'

    # Extract version from gemspec
    gemspec = File.read(gemspec_path)
    version_match = gemspec.match(/\.version\s*=\s*["']([^"']+)["']/)
    version = version_match[1] if version_match

    puts version
  else

    if input.nil?
      puts 'Usage: ./soroban_rust_backend <file_path>'
      exit(1)
    end

    json_for_web = silence_streams do
      SorobanRustBackend::ContractHandler.generate(DTRCore::Contract.from_dtr_raw(File.read(input)))
    end

    puts json_for_web
  end
end
