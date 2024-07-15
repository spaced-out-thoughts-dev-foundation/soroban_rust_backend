# frozen_string_literal: true

module SorobanRustBackend
  class LCPBT_Forrest
    attr_accessor :trees

    def initialize
      @trees = []
    end

    def add_tree(tree)
      @trees << tree
    end

    def traverse
      @trees.map(&:traverse)
    end

    def traverse_with_indentation
      @trees.compact.map(&:traverse_with_indentation)
    end

    # This represents a traversal through a unique path, covering all trees in the forest
    # only once. This is useful for code generation.
    def traverse_to_ids
      id_map = {}
      result = []

      traverse
        .map { |x| x.map(&:id) }
        .each do |x|
          sub_result = []
          x.each do |y|
            next if id_map[y]

            sub_result << y
            id_map[y] = true
          end
          result << sub_result
        end

      result
    end

    def code_generator_traverse(&block)
      traverse_with_indentation
        .map { |tree| tree.reverse.uniq.reverse.map(&block) }
    end

    def size
      @trees.size
    end

    def all_paths_to(instruction_id)
      @trees.map { |x| x.all_paths_to(instruction_id) }.flatten(1).compact
    end

    def walk_it
      @trees.each do |x|
        puts "Walking tree #{x.tree_id}"

        stack = []
        symbol_table = {}

        stack << x

        while stack.any?
          current = stack.pop

          if current.value.assign
            symbol_table[current.value.assign] = {
              value: current.value.id
            }
          end

          stack << current.left_child if current.left_child

          stack << current.right_child if current.right_child
        end
      end
    end
  end
end
