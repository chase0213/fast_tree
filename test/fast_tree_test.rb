require 'test_helper'

class FastTree::Test < ActiveSupport::TestCase

  test "create_tree should create root node" do
    root = TestTree.create_tree({name: "test root"})
    assert_equal 0, root.l_ptr
    assert_equal 1, root.r_ptr
    assert_equal "test root", root.name
  end

  test "find_subtree_by_root should find a subtree whose root is given node" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6})
    grand_child_1 = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    grand_child_2 = TestTree.create({name: "grand child", l_ptr: 4, r_ptr: 5})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8})

    subtree_of_root = TestTree.find_subtree_by_root(root)
    subtree_of_child = TestTree.find_subtree_by_root(child)
    subtree_of_child_out_of_scope = TestTree.find_subtree_by_root(child_out_of_scope)

    assert_equal 5, subtree_of_root.size
    assert_equal 3, subtree_of_child.size
    assert_equal 1, subtree_of_child_out_of_scope.size
  end

  test "add_child should create child node" do
    root = TestTree.create_tree({name: "test root"})
    child = root.add_child({name: "test child"})

    # must update variable
    root = TestTree.find_by(id: root.id)

    assert_equal 0, root.l_ptr
    assert_equal 3, root.r_ptr
    assert_equal 1, child.l_ptr
    assert_equal 2, child.r_ptr
    assert_equal "test child", child.name
  end

  test "add_child should create child node under given parent" do
    root = TestTree.create_tree({name: "test root"})
    child = root.add_child({name: "test child"})
    grand_child = child.add_child({name: "test grand child"})

    # must update variables
    root = TestTree.find_by(id: root.id)
    child = TestTree.find_by(id: child.id)

    assert_equal 0, root.l_ptr
    assert_equal 5, root.r_ptr
    assert_equal "test root", root.name
    assert_equal 1, child.l_ptr
    assert_equal 4, child.r_ptr
    assert_equal "test child", child.name
    assert_equal 2, grand_child.l_ptr
    assert_equal 3, grand_child.r_ptr
    assert_equal "test grand child", grand_child.name
  end

  test "add_child should create child node under given parent, not affecting others" do
    root = TestTree.create_tree({name: "test root"})
    child = root.add_child({name: "test child"})
    grand_child = child.add_child({name: "test grand child"})
    child_out_of_scope = root.add_child({name: "test child out of scope"})

    # must update variables
    root.reload
    child.reload
    child_out_of_scope.reload

    assert_equal 0, root.l_ptr
    assert_equal 7, root.r_ptr
    assert_equal "test root", root.name
    assert_equal 1, child.l_ptr
    assert_equal 4, child.r_ptr
    assert_equal "test child", child.name
    assert_equal 2, grand_child.l_ptr
    assert_equal 3, grand_child.r_ptr
    assert_equal 5, child_out_of_scope.l_ptr
    assert_equal 6, child_out_of_scope.r_ptr
    assert_equal "test child out of scope", child_out_of_scope.name
  end

  test "add_parent should create parent over given children" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grand_child = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

    # add parent over child
    parent = TestTree.add_parent([child], {name: "parent of child"})

    # must update variables
    root.reload
    child.reload
    grand_child.reload
    child_out_of_scope.reload

    assert_equal 0, root.l_ptr
    assert_equal 9, root.r_ptr
    assert_equal "root", root.name
    assert_equal 1, parent.l_ptr
    assert_equal 6, parent.r_ptr
    assert_equal "parent of child", parent.name
    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal "child", child.name
    assert_equal 3, grand_child.l_ptr
    assert_equal 4, grand_child.r_ptr
    assert_equal "grand child", grand_child.name
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal "child out of scope", child_out_of_scope.name
  end

  test "remove should remove a subtree" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grand_child = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

    # remove child node
    child.remove

    # must update variables
    root.reload
    child_out_of_scope.reload

    assert_equal 0, root.l_ptr
    assert_equal 3, root.r_ptr
    assert_equal 1, child_out_of_scope.l_ptr
    assert_equal 2, child_out_of_scope.r_ptr
  end

  test "copy_to should create a copy under given parent" do
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grand_child = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

    # copy a subtree to another node
    child.copy_to(child_out_of_scope)

    # must update variables
    root.reload
    child.reload
    grand_child.reload
    child_out_of_scope.reload

    assert_equal 0, root.l_ptr
    assert_equal 11, root.r_ptr
    assert_equal 1, child.l_ptr
    assert_equal 4, child.r_ptr
    assert_equal 2, grand_child.l_ptr
    assert_equal 3, grand_child.r_ptr
    assert_equal 5, child_out_of_scope.l_ptr
    assert_equal 10, child_out_of_scope.r_ptr
  end

  test "move_to should create a copy under given parent, and remove it" do
    #
    # <------->   ... root
    # _<--->      ... child
    # __<->       ... grand child
    # _____<->    ... child out of scope
    #
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 7})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 4})
    grand_child = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 5, r_ptr: 6})

    # move a subtree to another node
    child.move_to(child_out_of_scope)

    # must update variables
    root.reload
    child.reload
    grand_child.reload
    child_out_of_scope.reload

    assert_equal 0, root.l_ptr
    assert_equal 7, root.r_ptr
    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal 3, grand_child.l_ptr
    assert_equal 4, grand_child.r_ptr
    assert_equal 1, child_out_of_scope.l_ptr
    assert_equal 6, child_out_of_scope.r_ptr
  end

  test "depth should return depth of a node from the root" do
    #
    # <--------->   ... root
    # _<----->      ... child
    # __<->         ... grand child
    # ____<->       ... grand child
    # _______<->    ... child out of scope
    #
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6})
    grand_child_1 = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    grand_child_2 = TestTree.create({name: "grand child", l_ptr: 4, r_ptr: 5})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8})

    assert_equal 0, root.depth
    assert_equal 1, child.depth
    assert_equal 2, grand_child_1.depth
    assert_equal 2, grand_child_2.depth
    assert_equal 1, child_out_of_scope.depth
  end

  test "path should return a path from the root to a path" do
    #
    # <--------->   ... root
    # _<----->      ... child
    # __<->         ... grand child
    # ____<->       ... grand child
    # _______<->    ... child out of scope
    #
    root = TestTree.create({name: "root", l_ptr: 0, r_ptr: 9})
    child = TestTree.create({name: "child", l_ptr: 1, r_ptr: 6})
    grand_child_1 = TestTree.create({name: "grand child", l_ptr: 2, r_ptr: 3})
    grand_child_2 = TestTree.create({name: "grand child", l_ptr: 4, r_ptr: 5})
    child_out_of_scope = TestTree.create({name: "child out of scope", l_ptr: 7, r_ptr: 8})

    assert_equal [root], root.path
    assert_equal [root, child], child.path
    assert_equal [root, child, grand_child_1], grand_child_1.path
    assert_equal [root, child, grand_child_2], grand_child_2.path
    assert_equal [root, child_out_of_scope], child_out_of_scope.path
  end


end
