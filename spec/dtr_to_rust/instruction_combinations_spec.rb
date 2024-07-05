# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Instruction Combinations' do
  context 'when method invocation chain' do
    let(:minimal_dtr_code) do
      <<~DTR
        [Contract]: MyContract

        [Interface]:
          -() [hello_world]
            * Instructions:
            $
              { instruction: evaluate, input: (foo, 10), assign: EVALUATE_RESULT_A, scope: 0 }
              { instruction: evaluate, input: (EVALUATE_RESULT_A.bar), assign: EVALUATE_RESULT_B, scope: 0 }
              { instruction: evaluate, input: (EVALUATE_RESULT_B. baz, 10, "hello", false), scope: 0 }
            $


        :[Interface]

      DTR
    end

    let(:expected_rust_code) do
      <<~RUST
        #![no_std]
        use soroban_sdk::{contract, contractimpl, auth::Context, IntoVal, unwrap::UnwrapOptimized};

        #[contract]
        pub struct MyContract;

        #[contractimpl]
        impl MyContract {
          pub fn hello_world() {
            foo(10).bar().baz(10, "hello", false);
          }
        }
      RUST
    end

    it 'returns the optimized instructions' do
      actual = DTRToRust::Generator.generate_from_string(minimal_dtr_code).gsub("\n", '').gsub("\t", '').gsub(' ', '')
      expected = expected_rust_code.gsub("\n", '').gsub("\t", '').gsub(' ', '')

      expect(actual).to eq(expected)
    end
  end

  context 'when if statement' do
    let(:minimal_dtr_code) do
      <<~DTR
        [Contract]: LogIfAnswerToLife

        [Interface]:
          -() [fourty_two_and_then_some]
          * Inputs:
          {
            env: Env
            possibly_the_answer_to_life: Integer
          }
          * Instructions:
          $
            { instruction: evaluate, input: (equal_to, possibly_the_answer_to_life, ANSWER_TO_LIFE), assign: UNARY_ARGUMENT_0, scope: 0 }
            { instruction: evaluate, input: (!, UNARY_ARGUMENT_0), assign: CONDITIONAL_JUMP_ASSIGNMENT, scope: 0 }
            { instruction: jump, input: (CONDITIONAL_JUMP_ASSIGNMENT, 1), scope: 0 }
            { instruction: evaluate, input: (log_to_env, env, "Yes, the answer to life is 42!"), scope: 1 }
          $
        :[Interface]

        [State]:
          * [ANSWER_TO_LIFE]
            * Type: Integer
            * Initial Value: 42
        :[State]

        [Helpers]:
          -() [log_to_env]
          * Inputs:
          {
            env: Env
            message: String
          }
          * Instructions:
          $
            { instruction: print, input: (env, message), scope: 0 }
          $
        :[Helpers]
      DTR
    end

    let(:expected_rust_code) do
      <<~RUST
        #![no_std]
        use soroban_sdk::{contract, contractimpl, Env, log, Symbol, auth::Context, IntoVal, unwrap::UnwrapOptimized};

        const ANSWER_TO_LIFE: i128 = 42;

        #[contract]
        pub struct LogIfAnswerToLife;

        #[contractimpl]
        impl LogIfAnswerToLife {
            pub fn fourty_two_and_then_some(env: Env, possibly_the_answer_to_life: i128) {
              let CONDITIONAL_JUMP_ASSIGNMENT = !(possibly_the_answer_to_life == ANSWER_TO_LIFE);
              if CONDITIONAL_JUMP_ASSIGNMENT {
                log_to_env(&env, "Yes, the answer to life is 42!");
              }
            }
        }

        pub fn log_to_env(env: Env, message: Symbol) {
            log!(&env, message);
        }

      RUST
    end

    it 'returns the optimized instructions' do
      actual = DTRToRust::Generator.generate_from_string(minimal_dtr_code).gsub("\n", '').gsub("\t", '').gsub(' ', '')
      expected = expected_rust_code.gsub("\n", '').gsub("\t", '').gsub(' ', '')

      expect(actual).to eq(expected)
    end
  end

  context 'when if statement with else' do
    let(:minimal_dtr_code) do
      <<~DTR
        [Contract]: LogIfAnswerToLife

        [Interface]:
          -() [fourty_two_and_then_some]
          * Inputs:
          {
            env: Env
            possibly_the_answer_to_life: Integer
          }
          * Instructions:
          $
            { instruction: evaluate, input: (equal_to, possibly_the_answer_to_life, ANSWER_TO_LIFE), assign: UNARY_ARGUMENT_0, scope: 0 }
            { instruction: evaluate, input: (!, UNARY_ARGUMENT_0), assign: CONDITIONAL_JUMP_ASSIGNMENT, scope: 0 }
            { instruction: jump, input: (CONDITIONAL_JUMP_ASSIGNMENT, 1), scope: 0 }
            { instruction: evaluate, input: (log_to_env, env, "Yes, the answer to life is 42!"), scope: 1 }
            { instruction: jump, input: (101), scope: 0 }
            { instruction: evaluate, input: (log_to_env, env, "No, the answer to life is not that..."), scope: 101 }
          $
        :[Interface]

        [State]:
          * [ANSWER_TO_LIFE]
            * Type: Integer
            * Initial Value: 42
        :[State]

        [Helpers]:
          -() [log_to_env]
          * Inputs:
          {
            env: Env
            message: String
          }
          * Instructions:
          $
            { instruction: print, input: (env, message), scope: 0 }
          $
        :[Helpers]
      DTR
    end

    let(:expected_rust_code) do
      <<~RUST
        #![no_std]
        use soroban_sdk::{contract, contractimpl, Env, log, Symbol, auth::Context, IntoVal, unwrap::UnwrapOptimized};

        const ANSWER_TO_LIFE: i128 = 42;

        #[contract]
        pub struct LogIfAnswerToLife;

        #[contractimpl]
        impl LogIfAnswerToLife {
            pub fn fourty_two_and_then_some(env: Env, possibly_the_answer_to_life: i128) {
              let CONDITIONAL_JUMP_ASSIGNMENT = !(possibly_the_answer_to_life == ANSWER_TO_LIFE);
              if CONDITIONAL_JUMP_ASSIGNMENT {
                log_to_env(&env, "Yes, the answer to life is 42!");
              } else {
                log_to_env(&env, "No, the answer to life is not that...");
              }
            }
        }

        pub fn log_to_env(env: Env, message: Symbol) {
            log!(&env, message);
        }

      RUST
    end

    it 'returns the optimized instructions' do
      actual = DTRToRust::Generator.generate_from_string(minimal_dtr_code).gsub("\n", '').gsub("\t", '').gsub(' ', '')
      expected = expected_rust_code.gsub("\n", '').gsub("\t", '').gsub(' ', '')

      expect(actual).to eq(expected)
    end
  end

  context 'when nested if statements with elses' do
    let(:minimal_dtr_code) do
      <<~DTR
        [Contract]: LogIfAnswerToLife

        [Interface]:
          -() [fourty_two_and_then_some]
          * Inputs:
          {
            env: Env
            possibly_the_answer_to_life: Integer
          }
          * Instructions:
          $
            { instruction: evaluate, input: (equal_to, possibly_the_answer_to_life, ANSWER_TO_LIFE), assign: UNARY_ARGUMENT_0, scope: 0 }
            { instruction: evaluate, input: (!, UNARY_ARGUMENT_0), assign: CONDITIONAL_JUMP_ASSIGNMENT, scope: 0 }
            { instruction: jump, input: (CONDITIONAL_JUMP_ASSIGNMENT, 1), scope: 0 }
            { instruction: evaluate, input: (!, UNARY_ARGUMENT_0), assign: CONDITIONAL_JUMP_ASSIGNMENT, scope: 1 }
            { instruction: jump, input: (CONDITIONAL_JUMP_ASSIGNMENT, 2), scope: 1 }
            { instruction: evaluate, input: (log_to_env, env, "Yes, the answer to life is 42!"), scope: 2 }
            { instruction: jump, input: (201), scope: 1 }
            { instruction: evaluate, input: (log_to_env, env, "No, the answer to life is not that..."), scope: 201 }
            { instruction: evaluate, input: (!, UNARY_ARGUMENT_0), assign: CONDITIONAL_JUMP_ASSIGNMENT, scope: 201 }
            { instruction: jump, input: (CONDITIONAL_JUMP_ASSIGNMENT, 202), scope: 201 }
            { instruction: evaluate, input: (log_to_env, env, "Yes, the answer to life is 42!"), scope: 202 }
            { instruction: jump, input: (101), scope: 0 }
            { instruction: evaluate, input: (log_to_env, env, "No, the answer to life is not that..."), scope: 101 }
          $
        :[Interface]

        [State]:
          * [ANSWER_TO_LIFE]
            * Type: Integer
            * Initial Value: 42
        :[State]

        [Helpers]:
          -() [log_to_env]
          * Inputs:
          {
            env: Env
            message: String
          }
          * Instructions:
          $
            { instruction: print, input: (env, message), scope: 0 }
          $
        :[Helpers]
      DTR
    end

    let(:expected_rust_code) do
      <<~RUST
        #![no_std]
        use soroban_sdk::{contract, contractimpl, Env, log, Symbol, auth::Context, IntoVal, unwrap::UnwrapOptimized};

        const ANSWER_TO_LIFE: i128 = 42;

        #[contract]
        pub struct LogIfAnswerToLife;

        #[contractimpl]
        impl LogIfAnswerToLife {
            pub fn fourty_two_and_then_some(env: Env, possibly_the_answer_to_life: i128)  {
                let CONDITIONAL_JUMP_ASSIGNMENT = !(possibly_the_answer_to_life == ANSWER_TO_LIFE);
                if CONDITIONAL_JUMP_ASSIGNMENT {
                    let CONDITIONAL_JUMP_ASSIGNMENT = !(UNARY_ARGUMENT_0);
                    if CONDITIONAL_JUMP_ASSIGNMENT {
                        log_to_env(&env, "Yes, the answer to life is 42!");
                    }
                    else {
                      log_to_env(&env, "No, the answer to life is not that...");
                      let CONDITIONAL_JUMP_ASSIGNMENT = !(UNARY_ARGUMENT_0);
                      if CONDITIONAL_JUMP_ASSIGNMENT {
                          log_to_env(&env, "Yes, the answer to life is 42!");
                      }
                    }
                }
                else {
                    log_to_env(&env, "No, the answer to life is not that...");
                }
            }
        }

        pub fn log_to_env(env: Env, message: Symbol) {
            log!(&env, message);
        }

      RUST
    end

    it 'returns the optimized instructions' do
      actual = DTRToRust::Generator.generate_from_string(minimal_dtr_code).gsub("\n", '').gsub("\t", '').gsub(' ', '')
      expected = expected_rust_code.gsub("\n", '').gsub("\t", '').gsub(' ', '')

      expect(actual).to eq(expected)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
