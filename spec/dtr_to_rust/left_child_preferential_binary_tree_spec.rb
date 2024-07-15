# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SorobanRustBackend::LeftChildPreferentialBinaryTree do
  ### Tree structure
  ###
  #             1
  ###
  context 'when single node tree' do
    it 'is sane and traverses self' do
      node = described_class.new(1, metadata: {})
      expect(node.value).to eq(1)
      expect(node.left_child).to be_nil
      expect(node.right_child).to be_nil
      expect(node.traverse).to eq([1])
    end
  end

  ### Tree structure
  ###
  #             1
  #              \
  #               2
  ###
  context 'when two node tree' do
    it 'returns right child since left child is nil' do
      node1 = described_class.new(1, metadata: {})
      node2 = described_class.new(2, metadata: {})
      node1.set_right_child(node2)
      expect(node1.traverse).to eq([1, 2])
    end
  end

  ### Tree structure
  ###
  #             1
  #            / \
  #           2   3
  ###
  context 'when three node tree' do
    it 'traverses left first' do
      node1 = described_class.new(1, metadata: {})
      node2 = described_class.new(2, metadata: {})
      node3 = described_class.new(3, metadata: {})
      node1.set_left_child(node2)
      node1.set_right_child(node3)
      expect(node1.traverse).to eq([1, 2, 3])
    end
  end

  ### Tree structure
  ###
  #             1
  #            / \
  #           2   3
  #          / \
  #         4   5
  ###
  context 'when multi-node tree' do
    it 'traverses left first' do
      node1 = described_class.new(1, metadata: {})
      node2 = described_class.new(2, metadata: {})
      node3 = described_class.new(3, metadata: {})
      node4 = described_class.new(4, metadata: {})
      node5 = described_class.new(5, metadata: {})
      node1.set_left_child(node2)
      node1.set_right_child(node3)
      node2.set_left_child(node4)
      node2.set_right_child(node5)
      expect(node1.traverse).to eq([1, 2, 4, 5, 3])
    end
  end
end
