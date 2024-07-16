require 'dtr_core'

# This is the main module for the DTR to Rust gem.
module SorobanRustBackend
  autoload :LCPBT_Forrest, './lib/lcpbt_forrest'
  autoload :LeftChildPreferentialBinaryTree, './lib/left_child_preferential_binary_tree'
  autoload :Silviculturist, './lib/silviculturist'
  autoload :CodeGenerator, './lib/code_generator'
  autoload :Condenser, './lib/condenser'
  autoload :InstructionHandler, './lib/instruction_handler'
  autoload :UserDefinedTypesHandler, './lib/user_defined_types_handler'
  autoload :FunctionHandler, './lib/function_handler'
  autoload :ContractHandler, './lib/contract_handler'

  # This module contains all the classes that handle the different types of instructions.
  module Instruction
    autoload :Evaluate, './lib/instruction/evaluate'
    autoload :Field, './lib/instruction/field'
    autoload :Handler, './lib/instruction/handler'
    autoload :Print, './lib/instruction/print'
    autoload :Return, './lib/instruction/return'
    autoload :InstantiateObject, './lib/instruction/instantiate_object'
    autoload :Add, './lib/instruction/add'
    autoload :Subtract, './lib/instruction/subtract'
    autoload :Multiply, './lib/instruction/multiply'
    autoload :Divide, './lib/instruction/divide'
    autoload :Assign, './lib/instruction/assign'
    autoload :Jump, './lib/instruction/jump'
    autoload :Goto, './lib/instruction/goto'
    autoload :ExitWithMessage, './lib/instruction/exit_with_message'
    autoload :And, './lib/instruction/and'
    autoload :Or, './lib/instruction/or'
    autoload :EndOfIterationCheck, './lib/instruction/end_of_iteration_check'
    autoload :Increment, './lib/instruction/increment'
    autoload :TryAssign, './lib/instruction/try_assign'
    autoload :Break, './lib/instruction/break'
    autoload :BinaryInstruction, './lib/instruction/binary_instruction'
  end

  module Common
    autoload :TypeTranslator, './lib/common/type_translator'
    autoload :InputInterpreter, './lib/common/input_interpreter'
  end

  module NonTranslatables
    autoload :Handler, './lib/non_translatables/handler'
  end

  module ContractState
    autoload :Handler, './lib/contract_state/handler'
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
