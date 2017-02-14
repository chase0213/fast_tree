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
    @root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9, depth: 0})
    @child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6, depth: 1})
    @grandchild_1 = TestTree.create({name: "grand @child", l_ptr: 2, r_ptr: 3, depth: 2})
    @grandchild_2 = TestTree.create({name: "grand @child", l_ptr: 4, r_ptr: 5, depth: 2})
    @child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8, depth: 1})
  end

  test "create_tree should create root node" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create_tree(name: "test root")
    assert_equal 0, root.l_ptr
    assert_equal 1, root.r_ptr
    assert_equal 0, root.depth
    assert_equal "test root", root.name
  end

  test "find_subtree_by_root should find a subtree whose root is given node" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9, depth: 0})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6, depth: 1})
    grandchild_1 = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3, depth: 2})
    grandchild_2 = TestTree.create({name: "grand child", l_ptr: 4, r_ptr: 5, depth: 2})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8, depth: 1})

    subtree_of_root = TestTree.find_subtree_by_root(root)
    subtree_of_child = TestTree.find_subtree_by_root(child)
    subtree_of_child_out_of_scope = TestTree.find_subtree_by_root(child_out_of_scope)

    assert_equal 5, subtree_of_root.size
    assert_equal 3, subtree_of_child.size
    assert_equal 1, subtree_of_child_out_of_scope.size
  end

  test "add_parent over a node (not leaf) should create a parent over the node" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7, depth: 0})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4, depth: 1})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3, depth: 2})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6, depth: 1})

    # add parent over child
    parent = TestTree.create({name: "parent of child"})
    TestTree.add_parent(parent, [child])

    # must update variables
    root.reload
    child.reload
    grandchild.reload
    child_out_of_scope.reload
    parent.reload

    assert_equal 0, root.l_ptr
    assert_equal 9, root.r_ptr
    assert_equal 0, root.depth
    assert_equal "root", root.name
    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal 2, child.depth
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal 3, grandchild.depth
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal 1, child_out_of_scope.depth
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over child
    assert_equal 1, parent.l_ptr
    assert_equal 6, parent.r_ptr
    assert_equal 1, parent.depth
    assert_equal "parent of child", parent.name
  end

  test "add_parent over a leaf node should create a parent over the leaf" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7, depth: 0})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4, depth: 1})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3, depth: 2})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6, depth: 1})

    # add parent over child
    parent = TestTree.create({name: "parent of grandchild"})
    TestTree.add_parent(parent, [grandchild])

    # must update variables
    root.reload
    child.reload
    grandchild.reload
    child_out_of_scope.reload
    parent.reload

    assert_equal 0, root.l_ptr
    assert_equal 9, root.r_ptr
    assert_equal 0, root.depth
    assert_equal "root", root.name
    assert_equal 1, child.l_ptr
    assert_equal 6, child.r_ptr
    assert_equal 1, child.depth
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal 3, grandchild.depth
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal 1, child_out_of_scope.depth
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over grandchild
    assert_equal 2, parent.l_ptr
    assert_equal 5, parent.r_ptr
    assert_equal 2, parent.depth
    assert_equal "parent of grandchild", parent.name
  end

  test "add_parent over the root should create a new root" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7, depth: 0})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4, depth: 1})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3, depth: 2})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6, depth: 1})

    # add parent over child
    parent = TestTree.create({name: "parent of root"})
    TestTree.add_parent(parent, [root])

    # must update variables
    root.reload
    child.reload
    grandchild.reload
    child_out_of_scope.reload
    parent.reload

    # old root
    assert_equal 1, root.l_ptr
    assert_equal 8, root.r_ptr
    assert_equal 1, root.depth
    assert_equal "root", root.name

    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal 2, child.depth
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal 3, grandchild.depth
    assert_equal "grand child", grandchild.name
    assert_equal 6, child_out_of_scope.l_ptr
    assert_equal 7, child_out_of_scope.r_ptr
    assert_equal 2, child_out_of_scope.depth
    assert_equal "child out of scope", child_out_of_scope.name

    # new root
    assert_equal 0, parent.l_ptr
    assert_equal 9, parent.r_ptr
    assert_equal 0, parent.depth
    assert_equal "parent of root", parent.name
  end

  test "create_parent over a node (not leaf) should create a parent over the node" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7, depth: 0})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4, depth: 1})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3, depth: 2})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6, depth: 1})

    # create parent over child
    parent = TestTree.create_parent({name: "parent of child"}, [child])

    # must update variables
    root.reload
    child.reload
    grandchild.reload
    child_out_of_scope.reload
    parent.reload

    assert_equal 0, root.l_ptr
    assert_equal 9, root.r_ptr
    assert_equal 0, root.depth
    assert_equal "root", root.name
    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal 2, child.depth
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal 3, grandchild.depth
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal 1, child_out_of_scope.depth
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over child
    assert_equal 1, parent.l_ptr
    assert_equal 6, parent.r_ptr
    assert_equal 1, parent.depth
    assert_equal "parent of child", parent.name
  end

  test "create_parent over a leaf node should create a parent over the leaf" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7, depth: 0})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4, depth: 1})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3, depth: 2})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6, depth: 1})

    # create parent over grandchild
    parent = TestTree.create_parent({name: "parent of grandchild"}, [grandchild])

    # must update variables
    root.reload
    child.reload
    grandchild.reload
    child_out_of_scope.reload
    parent.reload

    assert_equal 0, root.l_ptr
    assert_equal 9, root.r_ptr
    assert_equal 0, root.depth
    assert_equal "root", root.name
    assert_equal 1, child.l_ptr
    assert_equal 6, child.r_ptr
    assert_equal 1, child.depth
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal 3, grandchild.depth
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal 1, child_out_of_scope.depth
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over grandchild
    assert_equal 2, parent.l_ptr
    assert_equal 5, parent.r_ptr
    assert_equal 2, parent.depth
    assert_equal "parent of grandchild", parent.name
  end

  test "create_parent over the root should create a new root" do
    # clear tree
    TestTree.destroy_all

    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7, depth: 0})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4, depth: 1})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3, depth: 2})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6, depth: 1})

    # create parent over root
    parent = TestTree.create_parent({name: "parent of root"}, [root])

    # must update variables
    root.reload
    child.reload
    grandchild.reload
    child_out_of_scope.reload
    parent.reload

    # old root
    assert_equal 1, root.l_ptr
    assert_equal 8, root.r_ptr
    assert_equal 1, root.depth
    assert_equal "root", root.name

    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal 2, child.depth
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal 3, grandchild.depth
    assert_equal "grand child", grandchild.name
    assert_equal 6, child_out_of_scope.l_ptr
    assert_equal 7, child_out_of_scope.r_ptr
    assert_equal 2, child_out_of_scope.depth
    assert_equal "child out of scope", child_out_of_scope.name

    # new root
    assert_equal 0, parent.l_ptr
    assert_equal 9, parent.r_ptr
    assert_equal 0, parent.depth
    assert_equal "parent of root", parent.name
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
    assert_equal 0, @root.depth
    assert_equal "root", @root.name
    assert_equal 1, @child.l_ptr
    assert_equal 8, @child.r_ptr
    assert_equal 1, @child.depth
    assert_equal "child", @child.name
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal 2, @grandchild_1.depth
    assert_equal "grand @child", @grandchild_1.name
    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth
    assert_equal "grand @child", @grandchild_2.name
    assert_equal 6, new_node.l_ptr
    assert_equal 7, new_node.r_ptr
    assert_equal 2, new_node.depth
    assert_equal "new node", new_node.name
    assert_equal 9, @child_out_of_scope.l_ptr
    assert_equal 10, @child_out_of_scope.r_ptr
    assert_equal 1, @child_out_of_scope.depth
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
    assert_equal 0, @root.depth
    assert_equal "root", @root.name
    assert_equal 1, @child.l_ptr
    assert_equal 8, @child.r_ptr
    assert_equal 1, @child.depth
    assert_equal "child", @child.name
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 5, @grandchild_1.r_ptr
    assert_equal 2, @grandchild_1.depth
    assert_equal "grand @child", @grandchild_1.name
    assert_equal 6, @grandchild_2.l_ptr
    assert_equal 7, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth
    assert_equal "grand @child", @grandchild_2.name
    assert_equal 3, new_node.l_ptr
    assert_equal 4, new_node.r_ptr
    assert_equal 3, new_node.depth
    assert_equal "new node", new_node.name
    assert_equal 9, @child_out_of_scope.l_ptr
    assert_equal 10, @child_out_of_scope.r_ptr
    assert_equal 1, @child_out_of_scope.depth
    assert_equal "child out of scope", @child_out_of_scope.name
  end

  test "create_child should create child node" do
    child_under_root = @root.create_child({name: "child under root"})

    # must update variable
    @root.reload

    assert_equal 0, @root.l_ptr
    assert_equal 11, @root.r_ptr
    assert_equal 0, @root.depth
    assert_equal 9, child_under_root.l_ptr
    assert_equal 10, child_under_root.r_ptr
    assert_equal 1, child_under_root.depth
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
    assert_equal 0, @root.depth
    assert_equal 1, @child.l_ptr
    assert_equal 8, @child.r_ptr
    assert_equal 1, @child.depth
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 5, @grandchild_1.r_ptr
    assert_equal 2, @grandchild_1.depth
    assert_equal 6, @grandchild_2.l_ptr
    assert_equal 7, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth
    assert_equal 9, @child_out_of_scope.l_ptr
    assert_equal 10, @child_out_of_scope.r_ptr
    assert_equal 1, @child_out_of_scope.depth
    assert_equal 3, child_under_grandchild.l_ptr
    assert_equal 4, child_under_grandchild.r_ptr
    assert_equal 3, child_under_grandchild.depth
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
    assert_equal 0, @root.depth
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal 2, @grandchild_1.depth
    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth
    assert_equal 7, @child_out_of_scope.l_ptr
    assert_equal 1, @child_out_of_scope.depth
  end

  test "remove a node (not leaf) should remove a subtree" do
    # remove @child node
    @child.remove

    # must update variables
    @root.reload
    @child_out_of_scope.reload

    assert_equal 0, @root.l_ptr
    assert_equal 3, @root.r_ptr
    assert_equal 0, @root.depth
    assert_equal 1, @child_out_of_scope.l_ptr
    assert_equal 2, @child_out_of_scope.r_ptr
    assert_equal 1, @child_out_of_scope.depth
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
    assert_equal 0, @root.depth
    assert_equal 1, @child.l_ptr
    assert_equal 4, @child.r_ptr
    assert_equal 1, @child.depth
    assert_equal 2, @grandchild_2.l_ptr
    assert_equal 3, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth
    assert_equal 5, @child_out_of_scope.l_ptr
    assert_equal 6, @child_out_of_scope.r_ptr
    assert_equal 1, @child_out_of_scope.depth
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
    assert_equal 0, @root.depth
    assert_equal 1, @child.l_ptr
    assert_equal 6, @child.r_ptr
    assert_equal 1, @child.depth
    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal 2, @grandchild_1.depth
    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth
    assert_equal 7, @child_out_of_scope.l_ptr
    assert_equal 14, @child_out_of_scope.r_ptr
    assert_equal 1, @child_out_of_scope.depth

    # nodes copied
    assert_equal 2, TestTree.find_by(l_ptr: 8, r_ptr: 13).depth
    assert_equal 3, TestTree.find_by(l_ptr: 9, r_ptr: 10).depth
    assert_equal 3, TestTree.find_by(l_ptr: 11, r_ptr: 12).depth
  end


  test "copy_to should create a copy under given parent with more complicated tree" do

    # clear tree
    TestTree.destroy_all

    #
    # Create a tree for testing
    #
    # <--------------->   ... root
    # _<----->            ... child
    # __<->               ... grandchild_1
    # ____<->             ... grandchild_2
    # _______<------->    ... another child
    # ________<--->       ... grandchild_3
    # _________<->        ... child of grandchild_3
    # ____________<->     ... grandchild_4
    #
    @root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 15, depth: 0})
    @child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6, depth: 1})
    @grandchild_1 = TestTree.create({name: "grandchild_1", l_ptr: 2, r_ptr: 3, depth: 2})
    @grandchild_2 = TestTree.create({name: "grandchild_2", l_ptr: 4, r_ptr: 5, depth: 2})
    @another_child = TestTree.create({name: "another child", l_ptr: 7, r_ptr: 14, depth: 1})
    @grandchild_3 = TestTree.create({name: "grandchild_3", l_ptr: 8, r_ptr: 11, depth: 2})
    @child_of_grandchild_3 = TestTree.create({name: "child of grandchild_3", l_ptr: 9, r_ptr: 10, depth: 3})
    @grandchild_4 = TestTree.create({name: "grandchild_4", l_ptr: 12, r_ptr: 13, depth: 2})

    # copy a subtree to another node
    @grandchild_3.copy_to(@child)

    # must update variables
    @root.reload
    @child.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @another_child.reload
    @grandchild_3.reload
    @child_of_grandchild_3.reload
    @grandchild_4.reload

    assert_equal 0, @root.l_ptr
    assert_equal 19, @root.r_ptr
    assert_equal 0, @root.depth

    assert_equal 1, @child.l_ptr
    assert_equal 10, @child.r_ptr
    assert_equal 1, @child.depth

    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal 2, @grandchild_1.depth

    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth

    assert_equal 11, @another_child.l_ptr
    assert_equal 18, @another_child.r_ptr
    assert_equal 1, @another_child.depth

    assert_equal 12, @grandchild_3.l_ptr
    assert_equal 15, @grandchild_3.r_ptr
    assert_equal 2, @grandchild_3.depth

    assert_equal 13, @child_of_grandchild_3.l_ptr
    assert_equal 14, @child_of_grandchild_3.r_ptr
    assert_equal 3, @child_of_grandchild_3.depth

    assert_equal 16, @grandchild_4.l_ptr
    assert_equal 17, @grandchild_4.r_ptr
    assert_equal 2, @grandchild_4.depth

    # nodes copied
    assert_equal 2, TestTree.find_by(l_ptr: 6, r_ptr: 9).depth
    assert_equal 3, TestTree.find_by(l_ptr: 7, r_ptr: 8).depth
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
    assert_equal 0, @root.depth
    assert_equal 2, @child.l_ptr
    assert_equal 7, @child.r_ptr
    assert_equal 2, @child.depth
    assert_equal 3, @grandchild_1.l_ptr
    assert_equal 4, @grandchild_1.r_ptr
    assert_equal 3, @grandchild_1.depth
    assert_equal 5, @grandchild_2.l_ptr
    assert_equal 6, @grandchild_2.r_ptr
    assert_equal 3, @grandchild_2.depth
    assert_equal 1, @child_out_of_scope.l_ptr
    assert_equal 8, @child_out_of_scope.r_ptr
    assert_equal 1, @child_out_of_scope.depth
  end


  test "move_to should create a copy under given parent and remove it with more complicated tree" do

    # clear tree
    TestTree.destroy_all

    #
    # Create a tree for testing
    #
    # <--------------->   ... root
    # _<----->            ... child
    # __<->               ... grandchild_1
    # ____<->             ... grandchild_2
    # _______<------->    ... another child
    # ________<--->       ... grandchild_3
    # _________<->        ... child of grandchild_3
    # ____________<->     ... grandchild_4
    #
    @root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 15, depth: 0})
    @child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6, depth: 1})
    @grandchild_1 = TestTree.create({name: "grandchild_1", l_ptr: 2, r_ptr: 3, depth: 2})
    @grandchild_2 = TestTree.create({name: "grandchild_2", l_ptr: 4, r_ptr: 5, depth: 2})
    @another_child = TestTree.create({name: "another child", l_ptr: 7, r_ptr: 14, depth: 1})
    @grandchild_3 = TestTree.create({name: "grandchild_3", l_ptr: 8, r_ptr: 11, depth: 2})
    @child_of_grandchild_3 = TestTree.create({name: "child of grandchild_3", l_ptr: 9, r_ptr: 10, depth: 3})
    @grandchild_4 = TestTree.create({name: "grandchild_4", l_ptr: 12, r_ptr: 13, depth: 2})

    # copy a subtree to another node
    @grandchild_3.move_to(@child)

    #
    # Create a tree for testing
    #
    # <--------------->   ... root
    # _<-------->         ... child
    # __<->               ... grandchild_1
    # ____<->             ... grandchild_2
    # ______<--->         ... grandchild_3
    # _______<->          ... child of grandchild_3
    # ___________<--->    ... another child
    # ____________<->     ... grandchild_4
    #

    # must update variables
    @root.reload
    @child.reload
    @grandchild_1.reload
    @grandchild_2.reload
    @another_child.reload
    @grandchild_3.reload
    @child_of_grandchild_3.reload
    @grandchild_4.reload

    assert_equal 0, @root.l_ptr
    assert_equal 15, @root.r_ptr
    assert_equal 0, @root.depth

    assert_equal 1, @child.l_ptr
    assert_equal 10, @child.r_ptr
    assert_equal 1, @child.depth

    assert_equal 2, @grandchild_1.l_ptr
    assert_equal 3, @grandchild_1.r_ptr
    assert_equal 2, @grandchild_1.depth

    assert_equal 4, @grandchild_2.l_ptr
    assert_equal 5, @grandchild_2.r_ptr
    assert_equal 2, @grandchild_2.depth

    assert_equal 11, @another_child.l_ptr
    assert_equal 14, @another_child.r_ptr
    assert_equal 1, @another_child.depth

    assert_equal 6, @grandchild_3.l_ptr
    assert_equal 9, @grandchild_3.r_ptr
    assert_equal 2, @grandchild_3.depth

    assert_equal 7, @child_of_grandchild_3.l_ptr
    assert_equal 8, @child_of_grandchild_3.r_ptr
    assert_equal 3, @child_of_grandchild_3.depth

    assert_equal 12, @grandchild_4.l_ptr
    assert_equal 13, @grandchild_4.r_ptr
    assert_equal 2, @grandchild_4.depth
  end


  test "path should return a path from the @root to a path" do
    assert_equal [@root], @root.path
    assert_equal [@root, @child], @child.path
    assert_equal [@root, @child, @grandchild_1], @grandchild_1.path
    assert_equal [@root, @child, @grandchild_2], @grandchild_2.path
    assert_equal [@root, @child_out_of_scope], @child_out_of_scope.path
  end

  test "root? should return true if the receiver is the root" do
    assert_equal true, @root.root?
  end

  test "root? should return false if the receiver is not the root" do
    assert_equal false, @child.root?
    assert_equal false, @grandchild_1.root?
    assert_equal false, @grandchild_2.root?
    assert_equal false, @child_out_of_scope.root?
  end

  test "leaf? should return true if the receiver is the leaf node" do
    assert_equal true, @grandchild_1.leaf?
    assert_equal true, @grandchild_2.leaf?
    assert_equal true, @child_out_of_scope.leaf?
  end

  test "leaf? should return false if the receiver is not the leaf node" do
    assert_equal false, @root.leaf?
    assert_equal false, @child.leaf?
  end

  test "has_children? should return true if the receiver has a child or children" do
    assert_equal true, @root.has_children?
    assert_equal true, @child.has_children?
  end

  test "has_children? should return false if the receiver has no children" do
    assert_equal false, @grandchild_1.has_children?
    assert_equal false, @grandchild_2.has_children?
    assert_equal false, @child_out_of_scope.has_children?
  end

end
