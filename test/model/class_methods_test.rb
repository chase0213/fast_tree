require 'test_helper'

class FastTree::Model::ClassMethods::Test < ActiveSupport::TestCase

  test "create_tree should create root node" do
    root = TestTree.create_tree(name: "test root")
    assert_equal 0, root.l_ptr
    assert_equal 1, root.r_ptr
    assert_equal "test root", root.name
  end

  test "find_subtree_by_root should find a subtree whose root is given node" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6})
    grandchild_1 = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    grandchild_2 = TestTree.create({name: "grand child", l_ptr: 4, r_ptr: 5})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8})

    subtree_of_root = TestTree.find_subtree_by_root(root)
    subtree_of_child = TestTree.find_subtree_by_root(child)
    subtree_of_child_out_of_scope = TestTree.find_subtree_by_root(child_out_of_scope)

    assert_equal 5, subtree_of_root.size
    assert_equal 3, subtree_of_child.size
    assert_equal 1, subtree_of_child_out_of_scope.size
  end

  test "add_parent over a node (not leaf) should create a parent over the node" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

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
    assert_equal "root", root.name
    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over child
    assert_equal 1, parent.l_ptr
    assert_equal 6, parent.r_ptr
    assert_equal "parent of child", parent.name
  end

  test "add_parent over a leaf node should create a parent over the leaf" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

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
    assert_equal "root", root.name
    assert_equal 1, child.l_ptr
    assert_equal 6, child.r_ptr
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over grandchild
    assert_equal 2, parent.l_ptr
    assert_equal 5, parent.r_ptr
    assert_equal "parent of grandchild", parent.name
  end

  test "add_parent over the root should create a new root" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

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
    assert_equal "root", root.name

    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal "grand child", grandchild.name
    assert_equal 6, child_out_of_scope.l_ptr
    assert_equal 7, child_out_of_scope.r_ptr
    assert_equal "child out of scope", child_out_of_scope.name

    # new root
    assert_equal 0, parent.l_ptr
    assert_equal 9, parent.r_ptr
    assert_equal "parent of root", parent.name
  end

  test "create_parent over a node (not leaf) should create a parent over the node" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

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
    assert_equal "root", root.name
    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over child
    assert_equal 1, parent.l_ptr
    assert_equal 6, parent.r_ptr
    assert_equal "parent of child", parent.name
  end

  test "create_parent over a leaf node should create a parent over the leaf" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

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
    assert_equal "root", root.name
    assert_equal 1, child.l_ptr
    assert_equal 6, child.r_ptr
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal "grand child", grandchild.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal "child out of scope", child_out_of_scope.name

    # new parent over grandchild
    assert_equal 2, parent.l_ptr
    assert_equal 5, parent.r_ptr
    assert_equal "parent of grandchild", parent.name
  end

  test "create_parent over the root should create a new root" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grandchild = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

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
    assert_equal "root", root.name

    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal "child", child.name
    assert_equal 3, grandchild.l_ptr
    assert_equal 4, grandchild.r_ptr
    assert_equal "grand child", grandchild.name
    assert_equal 6, child_out_of_scope.l_ptr
    assert_equal 7, child_out_of_scope.r_ptr
    assert_equal "child out of scope", child_out_of_scope.name

    # new root
    assert_equal 0, parent.l_ptr
    assert_equal 9, parent.r_ptr
    assert_equal "parent of root", parent.name
  end


end
