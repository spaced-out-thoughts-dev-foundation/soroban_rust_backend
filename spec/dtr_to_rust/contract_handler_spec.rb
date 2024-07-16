require 'spec_helper'

RSpec.describe SorobanRustBackend::ContractHandler do
  describe '.generate' do
    context 'when stellar example' do
      context 'when hello world contract' do
        let(:contract_name) { 'HelloWorldContract' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) { nil }
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'hello',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'to', type_name: 'String' }
              ],
              'List<String>',
              [
                ins(instruction: 'instantiate_object', inputs: ['List', '&env', '"Hello"', 'to'], assign: 'Thing_to_return', scope: 0,
                    id: 0),
                ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 1)
              ]
            )
          ]
        end
        let(:contract_helpers) {}
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contractimpl, Env, String, Vec, vec, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contract]
            pub struct HelloWorldContract;

            #[contractimpl]
            impl HelloWorldContract {
                pub fn hello(env: Env, to: String) -> Vec<String> {
                    let mut Thing_to_return: Vec<String>;
                    Thing_to_return = vec![&env, String::from_str(&env, "Hello"), to];
                    return Thing_to_return;
                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end

      context 'when increment contract' do
        let(:contract_name) { 'IncrementContract' }
        let(:contract_state) do
          [
            DTRCore::State.new(
              'COUNTER',
              'Symbol',
              '"COUNTER"'
            )
          ]
        end
        let(:contract_user_defined_types) { nil }
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'increment',
              [
                { name: 'env', type_name: 'Env' }
              ],
              'Integer',
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_6', scope: 0,
                    id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_6.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_5', scope: 0, id: 10),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_5.get', '&', 'COUNTER'],
                    assign: 'METHOD_CALL_EXPRESSION_2', scope: 0, id: 11),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_2.unwrap_or', '0'],
                    assign: 'count|||Integer', scope: 0, id: 12),
                ins(instruction: 'print', inputs: ['&env', '"count: {}"', 'count'], scope: 0, id: 13),
                ins(instruction: 'add', inputs: %w[count 1], assign: 'count', scope: 0, id: 18),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_24', scope: 0,
                    id: 27),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_24.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_23', scope: 0, id: 28),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_23.set', '&', 'COUNTER', '&', 'count'], scope: 0,
                    id: 29),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_35', scope: 0,
                    id: 38),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_35.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_34', scope: 0, id: 39),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_34.extend_ttl', '50', '100'], scope: 0,
                    id: 40),
                ins(instruction: 'return', inputs: ['count'], scope: 0, id: 0)
              ]
            )
          ]
        end
        let(:contract_helpers) { nil }
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{Symbol, symbol_short, contract, contractimpl, Env, log, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            const COUNTER: Symbol = symbol_short!("COUNTER");
            #[contract]
            pub struct IncrementContract;

            #[contractimpl]
            impl IncrementContract {
                pub fn increment(env: Env) -> i128 {
                    let mut Thing_to_return: i128;
                    let mut METHOD_CALL_EXPRESSION_6 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_5 = METHOD_CALL_EXPRESSION_6.instance();
                    let mut METHOD_CALL_EXPRESSION_2 = METHOD_CALL_EXPRESSION_5.get(&COUNTER);
                    let mut count: i128 = METHOD_CALL_EXPRESSION_2.unwrap_or(0);
                    log!(&env, "count: {}", count);
                    count = count + 1;
                    let mut METHOD_CALL_EXPRESSION_24 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_23 = METHOD_CALL_EXPRESSION_24.instance();
                    METHOD_CALL_EXPRESSION_23.set(&COUNTER, &count);
                    let mut METHOD_CALL_EXPRESSION_35 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_34 = METHOD_CALL_EXPRESSION_35.instance();
                    METHOD_CALL_EXPRESSION_34.extend_ttl(50, 100);
                    return count;
                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end

      context 'when errors contract' do
        let(:contract_name) { 'IncrementContract' }
        let(:contract_state) do
          [
            DTRCore::State.new(
              'COUNTER',
              'Symbol',
              '"COUNTER"'
            ),
            DTRCore::State.new(
              'MAX',
              'Integer',
              '5'
            )
          ]
        end
        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'Error_ENUM',
              [
                { name: 'LimitReached', type: '1' }
              ]
            )
          ]
        end
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'hello',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'to', type_name: 'String' }
              ],
              'Result<i128, Error>',
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_6', scope: 0,
                    id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_6.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_5', scope: 0, id: 10),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_5.get', '&', 'COUNTER'],
                    assign: 'METHOD_CALL_EXPRESSION_2', scope: 0, id: 11),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_2.unwrap_or', '0'],
                    assign: 'count|||Integer', scope: 0, id: 12),
                ins(instruction: 'print', inputs: ['&env', '"count: {}"', 'count'], scope: 0, id: 13),
                ins(instruction: 'add', inputs: %w[count 1], assign: 'count', scope: 0, id: 18),
                ins(instruction: 'evaluate', inputs: %w[less_than_or_equal_to count MAX],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_19', scope: 0, id: 24),
                ins(instruction: 'jump', inputs: %w[CONDITIONAL_JUMP_ASSIGNMENT_19 25], scope: 0, id: 26),
                ins(instruction: 'jump', inputs: ['44'], scope: 0, id: 45),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_32', scope: 25,
                    id: 35),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_32.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_31', scope: 25, id: 36),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_31.set', '&', 'COUNTER', '&', 'count'],
                    assign: 'METHOD_CALL_EXPRESSION_31', scope: 25, id: 37),
                ins(instruction: 'evaluate', inputs: %w[Ok count], assign: 'Thing_to_return', scope: 25, id: 42),
                ins(instruction: 'jump', inputs: ['0'], scope: 25, id: 43),
                ins(instruction: 'evaluate', inputs: ['Err', 'Error::LimitReached'], assign: 'Thing_to_return',
                    scope: 44, id: 50),
                ins(instruction: 'jump', inputs: ['0'], scope: 44, id: 51),
                ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 0)
              ]
            )
          ]
        end
        let(:contract_helpers) { nil }
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contracterror, Symbol, symbol_short, contractimpl, Env, String, log, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contracterror]
            #[derive(Copy, Clone, Debug, Eq, PartialEq, PartialOrd, Ord)]
            pub enum Error {
                LimitReached = 1,
            }

            const COUNTER: Symbol = symbol_short!("COUNTER");
            const MAX: i128 = 5;
            #[contract]
            pub struct IncrementContract;

            #[contractimpl]
            impl IncrementContract {
                pub fn hello(env: Env, to: String) -> Result<i128, Error> {
                    let mut Thing_to_return: Result<i128, Error>;
                    let mut METHOD_CALL_EXPRESSION_6 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_5 = METHOD_CALL_EXPRESSION_6.instance();
                    let mut METHOD_CALL_EXPRESSION_2 = METHOD_CALL_EXPRESSION_5.get(&COUNTER);
                    let mut count: i128 = METHOD_CALL_EXPRESSION_2.unwrap_or(0);
                    log!(&env, "count: {}", count);
                    count = count + 1;
                    let CONDITIONAL_JUMP_ASSIGNMENT_19 = count <= MAX;
                    if CONDITIONAL_JUMP_ASSIGNMENT_19 {
                        let mut METHOD_CALL_EXPRESSION_32 = env.storage();
                        let mut METHOD_CALL_EXPRESSION_31 = METHOD_CALL_EXPRESSION_32.instance();
                        let mut METHOD_CALL_EXPRESSION_31 = METHOD_CALL_EXPRESSION_31.set(&COUNTER, &count);
                        Thing_to_return = Ok(count);
                    }
                    else {
                        Thing_to_return = Err(Error::LimitReached);
                    }
                    return Thing_to_return;
                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end

      context 'when atomic multiswap contract' do
        let(:contract_name) { 'AtomicMultiSwapContract' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'SwapSpec_STRUCT',
              [
                { name: 'address', type: 'Address' },
                { name: 'amount', type: 'BigInteger' },
                { name: 'min_recv', type: 'BigInteger' }
              ]
            )
          ]
        end
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'multi_swap',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'swap_contract', type_name: 'Address' },
                { name: 'token_a', type_name: 'Address' },
                { name: 'token_b', type_name: 'Address' },
                { name: 'swaps_a', type_name: 'List<SwapSpec>' },
                { name: 'swaps_b', type_name: 'List<SwapSpec>' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['atomic_swap::Client::new', '&', 'env', '&', 'swap_contract'],
                    assign: 'swap_client', scope: 0, id: 7),
                ins(instruction: 'evaluate', inputs: ['swaps_a.iter'], assign: 'ITERATOR_8', scope: 0, id: 12),
                ins(instruction: 'evaluate', inputs: %w[start ITERATOR_8], assign: 'acc_a', scope: 0, id: 13),
                ins(instruction: 'end_of_iteration_check', inputs: %w[acc_a ITERATOR_8],
                    assign: 'CHECK_CONDITION_ASSIGNMENT_9', scope: 0, id: 14),
                ins(instruction: 'jump', inputs: ['CHECK_CONDITION_ASSIGNMENT_9', 15], scope: 0, id: 16),
                ins(instruction: 'evaluate', inputs: ['swaps_b.len'], assign: 'RANGE_END_20', scope: 15, id: 24),
                ins(instruction: 'instantiate_object', inputs: %w[Range 0 RANGE_END_20], assign: 'ITERATOR_17',
                    scope: 15, id: 25),
                ins(instruction: 'evaluate', inputs: %w[start ITERATOR_17], assign: 'i', scope: 15, id: 26),
                ins(instruction: 'end_of_iteration_check', inputs: %w[i ITERATOR_17],
                    assign: 'CHECK_CONDITION_ASSIGNMENT_18', scope: 15, id: 27),
                ins(instruction: 'jump', inputs: ['CHECK_CONDITION_ASSIGNMENT_18', 28], scope: 15, id: 29),
                ins(instruction: 'evaluate', inputs: ['swaps_b.get', 'i'], assign: 'METHOD_CALL_EXPRESSION_30',
                    scope: 28, id: 35),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_30.unwrap'], assign: 'acc_b', scope: 28,
                    id: 36),
                ins(instruction: 'evaluate', inputs: ['greater_than_or_equal_to', 'acc_a.amount', 'acc_b.min_recv'],
                    assign: 'BINARY_EXPRESSION_LEFT_38', scope: 28, id: 50),
                ins(instruction: 'evaluate', inputs: ['less_than_or_equal_to', 'acc_a.min_recv', 'acc_b.amount'],
                    assign: 'BINARY_EXPRESSION_RIGHT_39', scope: 28, id: 61),
                ins(instruction: 'and', inputs: %w[BINARY_EXPRESSION_LEFT_38 BINARY_EXPRESSION_RIGHT_39],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_37', scope: 28, id: 62),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_37', 63], scope: 28, id: 64),
                ins(instruction: 'evaluate',
                    inputs: ['swap_client.try_swap', '&', 'acc_a.address', '&', 'acc_b.address', '&', 'token_a', '&', 'token_b', '&', 'acc_a.amount', '&', 'acc_a.min_recv', '&', 'acc_b.amount', '&', 'acc_b.min_recv'], assign: 'METHOD_CALL_EXPRESSION_66', scope: 63, id: 103),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_66.is_ok'],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_65', scope: 63, id: 104),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_65', 105], scope: 63, id: 106),
                ins(instruction: 'evaluate', inputs: ['swaps_b.remove', 'i'], scope: 105, id: 111),
                ins(instruction: 'break', inputs: [], scope: 105, id: 112),
                ins(instruction: 'jump', inputs: ['63'], scope: 105, id: 113),
                ins(instruction: 'jump', inputs: ['28'], scope: 63, id: 114),
                ins(instruction: 'increment', inputs: %w[i ITERATOR_17], scope: 28, id: 115),
                ins(instruction: 'goto', inputs: ['27'], scope: 28, id: 116),
                ins(instruction: 'increment', inputs: %w[acc_a ITERATOR_8], scope: 15, id: 117),
                ins(instruction: 'goto', inputs: ['14'], scope: 15, id: 118)
              ]
            )
          ]
        end
        let(:contract_helpers) { nil }
        let(:contract_non_translatables) do
          'mod atomic_swap {
  soroban_sdk::contractimport!(
    file = "../atomic_swap/target/wasm32-unknown-unknown/release/soroban_atomic_swap_contract.wasm"
  );
}

'
        end

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contracttype, Address, contractimpl, Env, token, Vec, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            mod atomic_swap {
              soroban_sdk::contractimport!(
            		file = "../atomic_swap/target/wasm32-unknown-unknown/release/soroban_atomic_swap_contract.wasm"
            	);
            }

            #[contracttype]
            #[derive(Clone, Debug, Eq, PartialEq)]
            pub struct SwapSpec {
                pub address: Address,
                pub amount: i128,
                pub min_recv: i128,
            }

            #[contract]
            pub struct AtomicMultiSwapContract;

            #[contractimpl]
            impl AtomicMultiSwapContract {
              pub fn multi_swap(env: Env, swap_contract: Address, token_a: Address, token_b: Address, swaps_a: Vec<SwapSpec>, swaps_b: Vec<SwapSpec>)  {
                  let mut swap_client = atomic_swap::Client::new(&env, &swap_contract);
                  let mut ITERATOR_8 = swaps_a.iter();
                  let mut OPTION_acc_a = ITERATOR_8.next();
                  while let Some(acc_a) = OPTION_acc_a {
                    let mut RANGE_END_20 = swaps_b.len();
                    let mut ITERATOR_17 = 0..RANGE_END_20;
                    let mut OPTION_i = ITERATOR_17.next();
                    while let Some(i) = OPTION_i {
                      let mut METHOD_CALL_EXPRESSION_30 = swaps_b.get(i);
                      let mut acc_b = METHOD_CALL_EXPRESSION_30.unwrap();
                      let BINARY_EXPRESSION_LEFT_38 = acc_a.amount >= acc_b.min_recv;
                      let BINARY_EXPRESSION_RIGHT_39 = acc_a.min_recv <= acc_b.amount;
                      let CONDITIONAL_JUMP_ASSIGNMENT_37 = BINARY_EXPRESSION_LEFT_38 && BINARY_EXPRESSION_RIGHT_39;
                      if CONDITIONAL_JUMP_ASSIGNMENT_37 {
                        let mut METHOD_CALL_EXPRESSION_66 = swap_client.try_swap(&acc_a.address, &acc_b.address, &token_a, &token_b, &acc_a.amount, &acc_a.min_recv, &acc_b.amount, &acc_b.min_recv);
                        let mut CONDITIONAL_JUMP_ASSIGNMENT_65 = METHOD_CALL_EXPRESSION_66.is_ok();
                        if CONDITIONAL_JUMP_ASSIGNMENT_65 {
                          swaps_b.remove(i);
                          break;
                        }
                      }
                      OPTION_i = ITERATOR_17.next();
                    }
                  OPTION_acc_a = ITERATOR_8.next();
                }
              }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract).gsub("\t", '').gsub(' ',
                                                                        '').gsub("\n", '')).to eq(expected_output.gsub("\t", '').gsub(
                                                                          ' ', ''
                                                                        ).gsub("\n", ''))
        end
      end

      context 'when single offer contract' do
        let(:contract_name) { 'SingleOfferContract' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'DataKey_ENUM',
              [
                { name: 'Offer', type: '()' }
              ]
            ),
            DTRCore::UserDefinedType.new(
              'Offer_STRUCT',
              [
                { name: 'seller', type: 'Address' },
                { name: 'sell_token', type: 'Address' },
                { name: 'buy_token', type: 'Address' },
                { name: 'sell_price', type: 'Integer' },
                { name: 'buy_price', type: 'Integer' }
              ]
            )
          ]
        end

        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'create',
              [
                { name: 'e', type_name: 'Env' },
                { name: 'seller', type_name: 'Address' },
                { name: 'sell_token', type_name: 'Address' },
                { name: 'buy_token', type_name: 'Address' },
                { name: 'sell_price', type_name: 'Integer' },
                { name: 'buy_price', type_name: 'Integer' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['e.storage'], assign: 'METHOD_CALL_EXPRESSION_4', scope: 0,
                    id: 7),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_4.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_3', scope: 0, id: 8),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_3.has', '&', 'DataKey::Offer'],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_0', scope: 0, id: 9),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_0', 10], scope: 0, id: 11),
                ins(instruction: 'exit_with_message', inputs: ['"offer is already created"'], scope: 10, id: 12),
                ins(instruction: 'evaluate', inputs: %w[equal_to buy_price 0],
                    assign: 'BINARY_EXPRESSION_LEFT_15', scope: 0, id: 21),
                ins(instruction: 'evaluate', inputs: %w[equal_to sell_price 0],
                    assign: 'BINARY_EXPRESSION_RIGHT_16', scope: 0, id: 26),
                ins(instruction: 'or', inputs: %w[BINARY_EXPRESSION_LEFT_15 BINARY_EXPRESSION_RIGHT_16],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_14', scope: 0, id: 27),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_14', 28], scope: 0, id: 29),
                ins(instruction: 'exit_with_message', inputs: ['"zero price is not allowed"'], scope: 28, id: 30),
                ins(instruction: 'evaluate', inputs: ['seller.require_auth'], scope: 0, id: 34),
                ins(instruction: 'instantiate_object',
                    inputs: %w[& UDT Offer seller sell_token buy_token sell_price buy_price], assign: 'CALL_EXPRESSION_ARG_2_37', scope: 0, id: 43),
                ins(instruction: 'evaluate', inputs: %w[write_offer & e CALL_EXPRESSION_ARG_2_37], scope: 0, id: 47)
              ]
            ),
            DTRCore::Function.new(
              'trade',
              [
                { name: 'e', type_name: 'Env' },
                { name: 'buyer', type_name: 'Address' },
                { name: 'buy_token_amount', type_name: 'BigInteger' },
                { name: 'min_sell_token_amount', type_name: 'BigInteger' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['buyer.require_auth'], scope: 0, id: 50),
                ins(instruction: 'evaluate', inputs: %w[load_offer & e], assign: 'offer', scope: 0, id: 55),
                ins(instruction: 'evaluate', inputs: ['token::Client::new', '&', 'e', '&', 'offer.sell_token'],
                    assign: 'sell_token_client', scope: 0, id: 65),
                ins(instruction: 'evaluate', inputs: ['token::Client::new', '&', 'e', '&', 'offer.buy_token'],
                    assign: 'buy_token_client', scope: 0, id: 75),
                ins(instruction: 'evaluate', inputs: ['buy_token_amount.checked_mul', 'offer.sell_price'],
                    assign: 'METHOD_CALL_EXPRESSION_78', scope: 0, id: 86),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_78.unwrap_optimized'],
                    assign: 'BINARY_EXPRESSION_LEFT_76', scope: 0, id: 87),
                ins(instruction: 'divide', inputs: ['BINARY_EXPRESSION_LEFT_76', 'offer.buy_price'],
                    assign: 'sell_token_amount', scope: 0, id: 92),
                ins(instruction: 'evaluate', inputs: %w[less_than sell_token_amount min_sell_token_amount],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_93', scope: 0, id: 98),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_93', 99], scope: 0, id: 100),
                ins(instruction: 'exit_with_message', inputs: ['"price is too low"'], scope: 99, id: 101),
                ins(instruction: 'evaluate', inputs: ['e.current_contract_address'], assign: 'contract', scope: 0,
                    id: 105),
                ins(instruction: 'evaluate',
                    inputs: ['buy_token_client.transfer', '&', 'buyer', '&', 'contract', '&', 'buy_token_amount'], scope: 0, id: 114),
                ins(instruction: 'evaluate',
                    inputs: ['sell_token_client.transfer', '&', 'contract', '&', 'buyer', '&', 'sell_token_amount'], scope: 0, id: 123),
                ins(instruction: 'evaluate',
                    inputs: ['buy_token_client.transfer', '&', 'contract', '&', 'offer.seller', '&', 'buy_token_amount'], scope: 0, id: 135)
              ]
            ),
            DTRCore::Function.new(
              'withdraw',
              [
                { name: 'e', type_name: 'Env' },
                { name: 'token', type_name: 'Address' },
                { name: 'amount', type_name: 'BigInteger' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: %w[load_offer & e], assign: 'offer', scope: 0, id: 140),
                ins(instruction: 'evaluate', inputs: ['offer.seller.require_auth'], scope: 0, id: 146),
                ins(instruction: 'evaluate', inputs: ['token::Client::new', '&', 'e', '&', 'token'],
                    assign: 'METHOD_CALL_EXPRESSION_158', scope: 0, id: 165),
                ins(instruction: 'evaluate', inputs: ['&', 'e.current_contract_address'], assign: 'METHOD_CALL_ARG_1_147',
                    scope: 0, id: 150),
                ins(instruction: 'evaluate',
                    inputs: ['METHOD_CALL_EXPRESSION_158.transfer', 'METHOD_CALL_ARG_1_147', '&offer.seller', '&', 'amount'], scope: 0, id: 166)
              ]
            ),
            DTRCore::Function.new(
              'updt_price',
              [
                { name: 'e', type_name: 'Env' },
                { name: 'sell_price', type_name: 'Integer' },
                { name: 'buy_price', type_name: 'Integer' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: %w[equal_to buy_price 0], assign: 'BINARY_EXPRESSION_LEFT_168',
                    scope: 0, id: 174),
                ins(instruction: 'evaluate', inputs: %w[equal_to sell_price 0], assign: 'BINARY_EXPRESSION_RIGHT_169',
                    scope: 0, id: 179),
                ins(instruction: 'or', inputs: %w[BINARY_EXPRESSION_LEFT_168 BINARY_EXPRESSION_RIGHT_169],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_167', scope: 0, id: 180),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_167', 181], scope: 0, id: 182),
                ins(instruction: 'exit_with_message', inputs: ['"zero price is not allowed"'], scope: 181, id: 183),
                ins(instruction: 'evaluate', inputs: %w[load_offer & e], assign: 'offer', scope: 0, id: 189),
                ins(instruction: 'evaluate', inputs: ['offer.seller.require_auth'], scope: 0, id: 195),
                ins(instruction: 'assign', inputs: ['sell_price'], assign: 'offer.sell_price', scope: 0, id: 203),
                ins(instruction: 'assign', inputs: ['buy_price'], assign: 'offer.buy_price', scope: 0, id: 211),
                ins(instruction: 'evaluate', inputs: %w[write_offer & e & offer], scope: 0, id: 218)
              ]
            ),
            DTRCore::Function.new(
              'get_offer',
              [
                { name: 'e', type_name: 'Env' }
              ],
              'Offer',
              [
                ins(instruction: 'evaluate', inputs: %w[load_offer & e], assign: 'Thing_to_return', scope: 0, id: 223),
                ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 0)
              ]
            )
          ]
        end

        let(:contract_helpers) do
          [
            DTRCore::Function.new(
              'load_offer',
              [
                { name: 'env', type_name: '&Env' }
              ],
              'Offer',
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_4', scope: 0,
                    id: 7),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_4.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_3', scope: 0, id: 8),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_3.get', '&', 'DataKey::Offer'],
                    assign: 'METHOD_CALL_EXPRESSION_0', scope: 0, id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_0.unwrap'], assign: 'Thing_to_return',
                    scope: 0, id: 10),
                ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 0)
              ]
            ),
            DTRCore::Function.new(
              'write_offer',
              [
                { name: 'env', type_name: '&Env' },
                { name: 'offer', type_name: '&Offer' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_5', scope: 0,
                    id: 8),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_5.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_4', scope: 0, id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_4.set', '&', 'DataKey::Offer', 'offer'],
                    scope: 0, id: 10)
              ]
            )
          ]
        end
        let(:contract_non_translatables) { nil }
        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contracttype, Address, token, contractimpl, Env, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contracttype]
            #[derive(Clone, Debug, Eq, PartialEq)]
            pub enum DataKey {
                Offer,
            }

            #[contracttype]
            #[derive(Clone, Debug, Eq, PartialEq)]
            pub struct Offer {
                pub seller: Address,
                pub sell_token: Address,
                pub buy_token: Address,
                pub sell_price: i128,
                pub buy_price: i128,
            }

            #[contract]
            pub struct SingleOfferContract;

            #[contractimpl]
            impl SingleOfferContract {
                pub fn create(e: Env, seller: Address, sell_token: Address, buy_token: Address, sell_price: i128, buy_price: i128)  {
                    let mut METHOD_CALL_EXPRESSION_4 = e.storage();
                    let mut METHOD_CALL_EXPRESSION_3 = METHOD_CALL_EXPRESSION_4.instance();
                    let mut CONDITIONAL_JUMP_ASSIGNMENT_0 = METHOD_CALL_EXPRESSION_3.has(&DataKey::Offer);
                    if CONDITIONAL_JUMP_ASSIGNMENT_0 {
                        panic!("offer is already created");
                    }
                    let BINARY_EXPRESSION_LEFT_15 = buy_price == 0;
                    let BINARY_EXPRESSION_RIGHT_16 = sell_price == 0;
                    let CONDITIONAL_JUMP_ASSIGNMENT_14 = BINARY_EXPRESSION_LEFT_15 || BINARY_EXPRESSION_RIGHT_16;
                    if CONDITIONAL_JUMP_ASSIGNMENT_14 {
                        panic!("zero price is not allowed");
                    }
                    seller.require_auth();
                    let mut CALL_EXPRESSION_ARG_2_37 = &Offer{seller: seller, sell_token: sell_token, buy_token: buy_token, sell_price: sell_price, buy_price: buy_price};
                    write_offer(&e, CALL_EXPRESSION_ARG_2_37);
                }


                pub fn trade(e: Env, buyer: Address, buy_token_amount: i128, min_sell_token_amount: i128)  {
                    buyer.require_auth();
                    let mut offer = load_offer(&e);
                    let mut sell_token_client = token::Client::new(&e, &offer.sell_token);
                    let mut buy_token_client = token::Client::new(&e, &offer.buy_token);
                    let mut METHOD_CALL_EXPRESSION_78 = buy_token_amount.checked_mul(offer.sell_price);
                    let mut BINARY_EXPRESSION_LEFT_76 = METHOD_CALL_EXPRESSION_78.unwrap_optimized();
                    let mut sell_token_amount = BINARY_EXPRESSION_LEFT_76 / offer.buy_price;
                    let CONDITIONAL_JUMP_ASSIGNMENT_93 = sell_token_amount < min_sell_token_amount;
                    if CONDITIONAL_JUMP_ASSIGNMENT_93 {
                        panic!("price is too low");
                    }
                    let mut contract = e.current_contract_address();
                    buy_token_client.transfer(&buyer, &contract, &buy_token_amount);
                    sell_token_client.transfer(&contract, &buyer, &sell_token_amount);
                    buy_token_client.transfer(&contract, &offer.seller, &buy_token_amount);
                }


                pub fn withdraw(e: Env, token: Address, amount: i128)  {
                    let mut offer = load_offer(&e);
                    offer.seller.require_auth();
                    let mut METHOD_CALL_EXPRESSION_158 = token::Client::new(&e, &token);
                    let mut METHOD_CALL_ARG_1_147 = &e.current_contract_address();
                    METHOD_CALL_EXPRESSION_158.transfer(METHOD_CALL_ARG_1_147, &offer.seller, &amount);
                }


                pub fn updt_price(e: Env, sell_price: i128, buy_price: i128)  {
                    let BINARY_EXPRESSION_LEFT_168 = buy_price == 0;
                    let BINARY_EXPRESSION_RIGHT_169 = sell_price == 0;
                    let CONDITIONAL_JUMP_ASSIGNMENT_167 = BINARY_EXPRESSION_LEFT_168 || BINARY_EXPRESSION_RIGHT_169;
                    if CONDITIONAL_JUMP_ASSIGNMENT_167 {
                        panic!("zero price is not allowed");
                    }
                    let mut offer = load_offer(&e);
                    offer.seller.require_auth();
                    offer.sell_price = sell_price;
                    offer.buy_price = buy_price;
                    write_offer(&e, &offer);
                }


                pub fn get_offer(e: Env) -> Offer {
                    let mut Thing_to_return: Offer;
                    Thing_to_return = load_offer(&e);
                    return Thing_to_return;
                }
            }

            pub fn load_offer(env: &Env) -> Offer {
                let mut Thing_to_return: Offer;
                let mut METHOD_CALL_EXPRESSION_4 = env.storage();
                let mut METHOD_CALL_EXPRESSION_3 = METHOD_CALL_EXPRESSION_4.instance();
                let mut METHOD_CALL_EXPRESSION_0 = METHOD_CALL_EXPRESSION_3.get(&DataKey::Offer);
                Thing_to_return = METHOD_CALL_EXPRESSION_0.unwrap();
                return Thing_to_return;
            }


            pub fn write_offer(env: &Env, offer: &Offer)  {
                let mut METHOD_CALL_EXPRESSION_5 = env.storage();
                let mut METHOD_CALL_EXPRESSION_4 = METHOD_CALL_EXPRESSION_5.instance();
                METHOD_CALL_EXPRESSION_4.set(&DataKey::Offer, offer);
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract).gsub("\n", '').gsub("\t",
                                                                        '').gsub(' ', '')).to eq(expected_output.gsub("\n", '').gsub(
                                                                          "\t", ''
                                                                        ).gsub(' ', ''))
        end
      end

      context 'when custom types contract' do
        let(:contract_name) { 'IncrementContract' }
        let(:contract_state) do
          [
            DTRCore::State.new(
              'STATE',
              'String',
              '"STATE"'
            )
          ]
        end

        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'State_STRUCT',
              [
                { name: 'count', type: 'Integer' },
                { name: 'last_incr', type: 'Integer' }
              ]
            )
          ]
        end

        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'increment',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'incr', type_name: 'Integer' }
              ],
              'Integer',
              [
                ins(instruction: 'evaluate', inputs: ['env.clone'], assign: 'CALL_EXPRESSION_ARG_1_0', scope: 0, id: 3),
                ins(instruction: 'evaluate', inputs: %w[get_state CALL_EXPRESSION_ARG_1_0], assign: 'state',
                    scope: 0, id: 6),
                ins(instruction: 'add', inputs: %w[state.count incr], assign: 'state.count', scope: 0, id: 14),
                ins(instruction: 'assign', inputs: ['incr'], assign: 'state.last_incr', scope: 0, id: 22),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_28', scope: 0,
                    id: 31),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_28.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_27', scope: 0, id: 32),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_27.set', '&', 'STATE', '&', 'state'], scope: 0,
                    id: 33),
                ins(instruction: 'return', inputs: ['state.count'], scope: 0, id: 0)
              ]
            ),
            DTRCore::Function.new(
              'get_state',
              [
                { name: 'env', type_name: 'Env' }
              ],
              'State',
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_47', scope: 0,
                    id: 50),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_47.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_46', scope: 0, id: 51),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_46.get', '&', 'STATE'],
                    assign: 'METHOD_CALL_EXPRESSION_43', scope: 0, id: 52),
                ins(instruction: 'instantiate_object', inputs: %w[UDT State 0 0], assign: 'METHOD_CALL_ARG_1_38',
                    scope: 0, id: 41),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_43.unwrap_or', 'METHOD_CALL_ARG_1_38'],
                    assign: 'Thing_to_return', scope: 0, id: 53),
                ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 0)
              ]
            )
          ]
        end

        let(:contract_helpers) { nil }
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contracttype, Symbol, symbol_short, contractimpl, Env, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contracttype]
            #[derive(Clone, Debug, Eq, PartialEq)]
            pub struct State {
                pub count: i128,
                pub last_incr: i128,
            }

            const STATE: Symbol = symbol_short!("STATE");
            #[contract]
            pub struct IncrementContract;

            #[contractimpl]
            impl IncrementContract {
                pub fn increment(env: Env, incr: i128) -> i128 {
                    let mut Thing_to_return: i128;
                    let mut CALL_EXPRESSION_ARG_1_0 = env.clone();
                    let mut state = Self::get_state(CALL_EXPRESSION_ARG_1_0);
                    state.count = state.count + incr;
                    state.last_incr = incr;
                    let mut METHOD_CALL_EXPRESSION_28 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_27 = METHOD_CALL_EXPRESSION_28.instance();
                    METHOD_CALL_EXPRESSION_27.set(&STATE, &state);
                    return state.count;
                }


                pub fn get_state(env: Env) -> State {
                    let mut Thing_to_return: State;
                    let mut METHOD_CALL_EXPRESSION_47 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_46 = METHOD_CALL_EXPRESSION_47.instance();
                    let mut METHOD_CALL_EXPRESSION_43 = METHOD_CALL_EXPRESSION_46.get(&STATE);
                    let mut METHOD_CALL_ARG_1_38 = State{count: 0, last_incr: 0};
                    Thing_to_return = METHOD_CALL_EXPRESSION_43.unwrap_or(METHOD_CALL_ARG_1_38);
                    return Thing_to_return;
                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end

      context 'when logging contract' do
        let(:contract_name) { 'Contract' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) { nil }
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'log',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'value', type_name: 'String' }
              ],
              nil,
              [
                ins(instruction: 'print', inputs: ['&env', '"Hello {}"', 'value'], scope: 0, id: 0)
              ]
            )
          ]
        end
        let(:contract_helpers) { nil }
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contractimpl, log, Env, String, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contract]
            pub struct Contract;

            #[contractimpl]
            impl Contract {
                pub fn log(env: Env, value: String)  {
                    log!(&env, "Hello {}", value);
                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end

      context 'when simple account contract' do
        let(:contract_name) { 'SimpleAccount' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'DataKey_ENUM',
              [
                { name: 'Owner', type: '()' }
              ]
            )
          ]
        end

        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'init',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'public_key', type_name: 'ByteStringSmall' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_5', scope: 0,
                    id: 8),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_5.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_4', scope: 0, id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_4.has', '&', 'DataKey::Owner'],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_1', scope: 0, id: 10),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_1', 11], scope: 0, id: 12),
                ins(instruction: 'exit_with_message', inputs: ['"owner is already set"'], scope: 11, id: 13),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_20', scope: 0,
                    id: 23),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_20.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_19', scope: 0, id: 24),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_19.set', '&', 'DataKey::Owner', '&', 'public_key'],
                    scope: 0, id: 25)
              ]
            ),
            DTRCore::Function.new(
              '__check_auth',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'signature_payload', type_name: 'ByteStringSmall' },
                { name: 'signature', type_name: 'ByteStringLarge' },
                { name: '_auth_context', type_name: 'List<Context>' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_5', scope: 0,
                    id: 8),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_5.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_4', scope: 0, id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_4.get', '&', 'DataKey::Owner'],
                    assign: 'METHOD_CALL_EXPRESSION_1', scope: 0, id: 10),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_1.unwrap'], assign: 'public_key',
                    scope: 0, id: 11),
                ins(instruction: 'evaluate', inputs: ['env.crypto'], assign: 'METHOD_CALL_EXPRESSION_20', scope: 0,
                    id: 23),
                ins(instruction: 'evaluate', inputs: ['&', 'signature_payload.into'], assign: 'METHOD_CALL_ARG_2_14',
                    scope: 0, id: 17),
                ins(instruction: 'evaluate',
                    inputs: ['METHOD_CALL_EXPRESSION_20.ed25519_verify', '&', 'public_key', 'METHOD_CALL_ARG_2_14', '&', 'signature'], scope: 0, id: 24)
              ]
            )
          ]
        end
        let(:contract_helpers) { nil }
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contracttype, contractimpl, Env, BytesN, Vec, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contracttype]
            #[derive(Clone, Debug, Eq, PartialEq)]
            pub enum DataKey {
                Owner,
            }

            #[contract]
            pub struct SimpleAccount;

            #[contractimpl]
            impl SimpleAccount {
                pub fn init(env: Env, public_key: BytesN<32>)  {
                    let mut METHOD_CALL_EXPRESSION_5 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_4 = METHOD_CALL_EXPRESSION_5.instance();
                    let mut CONDITIONAL_JUMP_ASSIGNMENT_1 = METHOD_CALL_EXPRESSION_4.has(&DataKey::Owner);
                    if CONDITIONAL_JUMP_ASSIGNMENT_1 {
                        panic!("owner is already set");
                    }
                    let mut METHOD_CALL_EXPRESSION_20 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_19 = METHOD_CALL_EXPRESSION_20.instance();
                    METHOD_CALL_EXPRESSION_19.set(&DataKey::Owner, &public_key);
                }


                pub fn __check_auth(env: Env, signature_payload: BytesN<32>, signature: BytesN<64>, _auth_context: Vec<Context>)  {
                    let mut METHOD_CALL_EXPRESSION_5 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_4 = METHOD_CALL_EXPRESSION_5.instance();
                    let mut METHOD_CALL_EXPRESSION_1 = METHOD_CALL_EXPRESSION_4.get(&DataKey::Owner);
                    let mut public_key = METHOD_CALL_EXPRESSION_1.unwrap();
                    let mut METHOD_CALL_EXPRESSION_20 = env.crypto();
                    let mut METHOD_CALL_ARG_2_14 = &signature_payload.into();
                    METHOD_CALL_EXPRESSION_20.ed25519_verify(&public_key, METHOD_CALL_ARG_2_14, &signature);
                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end

      context 'when ttl contract' do
        let(:contract_name) { 'TtlContract' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'DataKey_ENUM',
              [
                { name: 'MyKey', type: '()' }
              ]
            )
          ]
        end

        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'setup',
              [
                { name: 'env', type_name: 'Env' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_5', scope: 0,
                    id: 8),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_5.persistent'],
                    assign: 'METHOD_CALL_EXPRESSION_4', scope: 0, id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_4.set', '&', 'DataKey::MyKey', '&', 0], scope: 0,
                    id: 10),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_16', scope: 0,
                    id: 19),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_16.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_15', scope: 0, id: 20),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_15.set', '&', 'DataKey::MyKey', '&', 1], scope: 0,
                    id: 21),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_27', scope: 0,
                    id: 30),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_27.temporary'],
                    assign: 'METHOD_CALL_EXPRESSION_26', scope: 0, id: 31),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_26.set', '&', 'DataKey::MyKey', '&', 2], scope: 0,
                    id: 32)
              ]
            ),
            DTRCore::Function.new(
              'extend_persistent',
              [
                { name: 'env', type_name: 'Env' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_40', scope: 0,
                    id: 43),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_40.persistent'],
                    assign: 'METHOD_CALL_EXPRESSION_39', scope: 0, id: 44),
                ins(instruction: 'evaluate',
                    inputs: ['METHOD_CALL_EXPRESSION_39.extend_ttl', '&', 'DataKey::MyKey', 1000, 5000], scope: 0, id: 45)
              ]
            ),
            DTRCore::Function.new(
              'extend_instance',
              [
                { name: 'env', type_name: 'Env' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_51', scope: 0,
                    id: 54),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_51.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_50', scope: 0, id: 55),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_50.extend_ttl', 2000, 10_000], scope: 0,
                    id: 56)
              ]
            ),
            DTRCore::Function.new(
              'extend_temporary',
              [
                { name: 'env', type_name: 'Env' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_64', scope: 0,
                    id: 67),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_64.temporary'],
                    assign: 'METHOD_CALL_EXPRESSION_63', scope: 0, id: 68),
                ins(instruction: 'evaluate',
                    inputs: ['METHOD_CALL_EXPRESSION_63.extend_ttl', '&', 'DataKey::MyKey', 3000, 7000], scope: 0, id: 69)
              ]
            )
          ]
        end

        let(:contract_helpers) { nil }
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contracttype, contractimpl, Env, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contracttype]
            #[derive(Clone, Debug, Eq, PartialEq)]
            pub enum DataKey {
                MyKey,
            }

            #[contract]
            pub struct TtlContract;

            #[contractimpl]
            impl TtlContract {
                pub fn setup(env: Env)  {
                    let mut METHOD_CALL_EXPRESSION_5 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_4 = METHOD_CALL_EXPRESSION_5.persistent();
                    METHOD_CALL_EXPRESSION_4.set(&DataKey::MyKey, &0);
                    let mut METHOD_CALL_EXPRESSION_16 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_15 = METHOD_CALL_EXPRESSION_16.instance();
                    METHOD_CALL_EXPRESSION_15.set(&DataKey::MyKey, &1);
                    let mut METHOD_CALL_EXPRESSION_27 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_26 = METHOD_CALL_EXPRESSION_27.temporary();
                    METHOD_CALL_EXPRESSION_26.set(&DataKey::MyKey, &2);
                }


                pub fn extend_persistent(env: Env)  {
                    let mut METHOD_CALL_EXPRESSION_40 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_39 = METHOD_CALL_EXPRESSION_40.persistent();
                    METHOD_CALL_EXPRESSION_39.extend_ttl(&DataKey::MyKey, 1000, 5000);
                }


                pub fn extend_instance(env: Env)  {
                    let mut METHOD_CALL_EXPRESSION_51 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_50 = METHOD_CALL_EXPRESSION_51.instance();
                    METHOD_CALL_EXPRESSION_50.extend_ttl(2000, 10000);
                }


                pub fn extend_temporary(env: Env)  {
                    let mut METHOD_CALL_EXPRESSION_64 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_63 = METHOD_CALL_EXPRESSION_64.temporary();
                    METHOD_CALL_EXPRESSION_63.extend_ttl(&DataKey::MyKey, 3000, 7000);
                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end
    end
  end
end
