# This is the main module for the DTR to Rust gem.
module SorobanRustBackend
  autoload :LCPBT_Forrest, 'lcpbt_forrest'
  autoload :LeftChildPreferentialBinaryTree, 'left_child_preferential_binary_tree'
  autoload :Silviculturist, 'silviculturist'
  autoload :CodeGenerator, 'code_generator'
  autoload :Condenser, 'condenser'
  autoload :InstructionHandler, 'instruction_handler'
  autoload :UserDefinedTypesHandler, 'user_defined_types_handler'
  autoload :FunctionHandler, 'function_handler'
  autoload :ContractHandler, 'contract_handler'

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
