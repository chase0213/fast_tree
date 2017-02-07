require 'test_helper'

class FastTree::Model::Test < ActiveSupport::TestCase

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
    @root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9})
    @child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6})
    @grandchild_1 = TestTree.create({name: "grand @child", l_ptr: 2, r_ptr: 3})
    @grandchild_2 = TestTree.create({name: "grand @child", l_ptr: 4, r_ptr: 5})
    @child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8})
  end

  test "add_child should add @child node under given parent" do
    new_node = TestTree.create({name: "new node"})
    @child.add_child(new_node)

    @root.reload
    @child.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @child_out_of_scope.reload
    new_node.reload

    assert_equal 0, @root.l_ptr
    assert_equal 11, @root.r_ptr
    assert_equal "root", @root.name
    assert_equal 1, @child.l_ptr
    assert_equal 8, @child.r_ptr
    assert_equal "child", @child.name
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal "grand @child", @grandchild_1.name
    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal "grand @child", @grandchild_2.name
    assert_equal 6, new_node.l_ptr
    assert_equal 7, new_node.r_ptr
    assert_equal "new node", new_node.name
    assert_equal 9, @child_out_of_scope.l_ptr
    assert_equal 10, @child_out_of_scope.r_ptr
    assert_equal "child out of scope", @child_out_of_scope.name
  end

  test "add_child should add child node under given parent and move nodes" do
    new_node = TestTree.create({name: "new node"})
    @grandchild_1.add_child(new_node)

    @root.reload
    @child.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @child_out_of_scope.reload
    new_node.reload

    assert_equal 0, @root.l_ptr
    assert_equal 11, @root.r_ptr
    assert_equal "root", @root.name
    assert_equal 1, @child.l_ptr
    assert_equal 8, @child.r_ptr
    assert_equal "child", @child.name
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 5, @grandchild_1.r_ptr
    assert_equal "grand @child", @grandchild_1.name
    assert_equal 6, @grandchild_2.l_ptr
    assert_equal 7, @grandchild_2.r_ptr
    assert_equal "grand @child", @grandchild_2.name
    assert_equal 3, new_node.l_ptr
    assert_equal 4, new_node.r_ptr
    assert_equal "new node", new_node.name
    assert_equal 9, @child_out_of_scope.l_ptr
    assert_equal 10, @child_out_of_scope.r_ptr
    assert_equal "child out of scope", @child_out_of_scope.name
  end

  test "create_child should create child node" do
    child_under_root = @root.create_child({name: "child under root"})

    # must update variable
    @root.reload

    assert_equal 0, @root.l_ptr
    assert_equal 11, @root.r_ptr
    assert_equal 9, child_under_root.l_ptr
    assert_equal 10, child_under_root.r_ptr
    assert_equal "child under root", child_under_root.name
  end

  test "create_child should create child node under given parent, not affecting others" do
    child_under_grandchild = @grandchild_1.create_child({name: "child under grandchild"})

    # must update variables
    @root.reload
    @child.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @child_out_of_scope.reload

    assert_equal 0, @root.l_ptr
    assert_equal 11, @root.r_ptr
    assert_equal 1, @child.l_ptr
    assert_equal 8, @child.r_ptr
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 5, @grandchild_1.r_ptr
    assert_equal 6, @grandchild_2.l_ptr
    assert_equal 7, @grandchild_2.r_ptr
    assert_equal 9, @child_out_of_scope.l_ptr
    assert_equal 10, @child_out_of_scope.r_ptr
    assert_equal 3, child_under_grandchild.l_ptr
    assert_equal 4, child_under_grandchild.r_ptr
    assert_equal "child under grandchild", child_under_grandchild.name
  end

  test "destroy should remove a node and not affect the others" do
    # remove @child node
    @child.destroy

    # must update variables
    @root.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @child_out_of_scope.reload

    assert_equal 0, @root.l_ptr
    assert_equal 9, @root.r_ptr
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal 7, @child_out_of_scope.l_ptr
    assert_equal 8, @child_out_of_scope.r_ptr
  end

  test "remove a node (not leaf) should remove a subtree" do
    # remove @child node
    @child.remove

    # must update variables
    @root.reload
    @child_out_of_scope.reload

    assert_equal 0, @root.l_ptr
    assert_equal 3, @root.r_ptr
    assert_equal 1, @child_out_of_scope.l_ptr
    assert_equal 2, @child_out_of_scope.r_ptr
  end

  test "remove a leaf should remove only the leaf" do
    @grandchild_1.remove

    # must update variables
    @root.reload
    @child.reload
    @grandchild_2.reload
    @child_out_of_scope.reload

    assert_equal 0, @root.l_ptr
    assert_equal 7, @root.r_ptr
    assert_equal 1, @child.l_ptr
    assert_equal 4, @child.r_ptr
    assert_equal 2, @grandchild_2.l_ptr
    assert_equal 3, @grandchild_2.r_ptr
    assert_equal 5, @child_out_of_scope.l_ptr
    assert_equal 6, @child_out_of_scope.r_ptr
  end

  test "copy_to should create a copy under given parent" do
    # copy a subtree to another node
    @child.copy_to(@child_out_of_scope)

    # must update variables
    @root.reload
    @child.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @child_out_of_scope.reload

    assert_equal 0, @root.l_ptr
    assert_equal 15, @root.r_ptr
    assert_equal 1, @child.l_ptr
    assert_equal 6, @child.r_ptr
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal 7, @child_out_of_scope.l_ptr
    assert_equal 14, @child_out_of_scope.r_ptr
  end

  test "move_to should create a copy under given parent, and remove it" do
    # move a subtree to another node
    @child.move_to(@child_out_of_scope)

    # must update variables
    @root.reload
    @child.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @child_out_of_scope.reload

    assert_equal 0, @root.l_ptr
    assert_equal 9, @root.r_ptr
    assert_equal 2, @child.l_ptr
    assert_equal 7, @child.r_ptr
    assert_equal 3, @grandchild_1.l_ptr
    assert_equal 4, @grandchild_1.r_ptr
    assert_equal 5, @grandchild_2.l_ptr
    assert_equal 6, @grandchild_2.r_ptr
    assert_equal 1, @child_out_of_scope.l_ptr
    assert_equal 8, @child_out_of_scope.r_ptr
  end

  test "depth should return depth of a node from the @root" do
    assert_equal 0, @root.depth
    assert_equal 1, @child.depth
    assert_equal 2, @grandchild_1.depth
    assert_equal 2, @grandchild_2.depth
    assert_equal 1, @child_out_of_scope.depth
  end

  test "path should return a path from the @root to a path" do
    assert_equal [@root], @root.path
    assert_equal [@root, @child], @child.path
    assert_equal [@root, @child, @grandchild_1], @grandchild_1.path
    assert_equal [@root, @child, @grandchild_2], @grandchild_2.path
    assert_equal [@root, @child_out_of_scope], @child_out_of_scope.path
  end

end
