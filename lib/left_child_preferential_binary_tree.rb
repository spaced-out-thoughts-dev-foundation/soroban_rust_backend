require 'securerandom'

module SorobanRustBackend
  class LeftChildPreferentialBinaryTree
    attr_accessor :value, :left_child, :right_child, :tree_id, :metadata

    def initialize(value, metadata:, indentation: 0)
      @tree_id = SecureRandom.uuid
      @indentation = indentation
      @value = value
      @left_child = nil
      @right_child = nil
      @metadata = metadata
    end

    def set_left_child(node)
      raise 'Left child already exists' if @left_child

      @left_child = node
    end

    def set_right_child(node)
      raise 'Right child already exists' if @right_child

      @right_child = node
    end

    def traverse
      result = []
      result << @value
      result += @left_child.traverse if @left_child
      result += @right_child.traverse if @right_child
      result
    end

    def traverse_with_indentation
      result = []
      result << [@value, @indentation, @metadata]
      result += @left_child.traverse_with_indentation if @left_child
      result += @right_child.traverse_with_indentation if @right_child
      result
    end

    def all_paths_to(instruction_id, cur_result: [])
      if value.id == instruction_id
        return cur_result.empty? ? [[instruction_id]] : cur_result + [instruction_id]
      end

      result = nil

      if @left_child
        left_child_traverse = @left_child.all_paths_to(instruction_id, cur_result: cur_result + [value.id])
        result = left_child_traverse unless left_child_traverse.nil?
      end

      if @right_child
        right_child_traverse = @right_child.all_paths_to(instruction_id, cur_result: cur_result + [value.id])
        result = result.nil? ? right_child_traverse : [result, right_child_traverse]
      end

      result
    end
  end
end
