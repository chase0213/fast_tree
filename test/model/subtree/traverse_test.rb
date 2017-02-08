require 'test_helper'

class FastTree::Model::Subtree::Traverse::Test < ActiveSupport::TestCase

  setup do
    #
    # Create a tree for testing
    #
    # <--------->   ... @root
    # _<----->      ... @child
    # __<->         ... grand @child
    # ____<->       ... grand @child
    # _______<->    ... @child out of scope
    #
    @root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9, depth: 0})
    @child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8, depth: 1})
    @child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6, depth: 1})
    @grandchild_1 = TestTree.create({name: "grand @child", l_ptr: 2, r_ptr: 3, depth: 2})
    @grandchild_2 = TestTree.create({name: "grand @child", l_ptr: 4, r_ptr: 5, depth: 2})
  end

  test "each should be implemented" do
    count = 0
    @root.subtree.each do |node|
      assert_equal true, node.is_a?(TestTree)
      count += 1
    end
    assert_equal 5, count
  end

  test "map should be implemented" do
    nodes = @root.subtree.map {|node|
      node.id
    }
    assert_equal 5, nodes.size
    assert_equal true, nodes[0].is_a?(Fixnum)
  end

  test "dfs should be implemented" do
    dfs_ordered_nodes = [
      @root, @child, @grandchild_1, @grandchild_2, @child_out_of_scope
    ]

    count = 0
    @root.subtree.dfs.each do |node|
      assert_equal dfs_ordered_nodes[count], node
      count += 1
    end
    assert_equal 5, count
  end

  test "bfs should be implemented" do
    bfs_ordered_nodes = [
      @root, @child, @child_out_of_scope, @grandchild_1, @grandchild_2
    ]

    count = 0
    @root.subtree.bfs.each do |node|
      assert_equal bfs_ordered_nodes[count], node
      count += 1
    end
    assert_equal 5, count
  end

end
