# frozen_string_literal: true

# This is the main module for the DTR to Rust gem.
module DTRToRust
  autoload :Generator, './lib/generator'
  autoload :InstructionHandler, './lib/instruction_handler'

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
    autoload :Label, './lib/instruction/label'
    autoload :EndOfIterationCheck, './lib/instruction/end_of_iteration_check'
    autoload :Increment, './lib/instruction/increment'
  end

  # This module contains all the classes that handle common logic.
  module Common
    autoload :InputInterpreter, './lib/common/input_interpreter'
    autoload :ReferenceAppender, './lib/common/reference_appender'
    autoload :TypeTranslator, './lib/common/type_translator'
  end

  # This module contains all the classes that handle optimization.
  module Optimization
    autoload :ChainedInvocationAssignmentReduction, './lib/optimization/chained_invocation_assignment_reduction'
    autoload :FieldToAssignmentConversion, './lib/optimization/field_to_assignment_conversion'
    autoload :BinaryXToSelfAssignmentReduction, './lib/optimization/binary_x_to_self_assignment_reduction'
  end

  # This module contains all the classes that handle user defined types.
  module UserDefinedTypes
    autoload :Handler, './lib/user_defined_types/handler'
  end

  # This module contains all the classes that handle the aggregation of instructions.
  module Aggregator
    autoload :ScopeBlockAggregator, './lib/aggregator/scope_block_aggregator'
    autoload :LoopAggregator, './lib/aggregator/loop_aggregator'
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
      puts 'Usage: ./dtr_to_rust <file_path>'
      exit(1)
    end

    json_for_web = silence_streams do
      DTRToRust::Generator.generate_from_file(input)
    end

    puts json_for_web
  end
end
