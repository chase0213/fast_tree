require 'test_helper'

class FastTree::Test < ActiveSupport::TestCase

  test "test create_tree should create root node" do
    root = TestTree.create_tree({name: "test root"})
    assert_equal 0, root.l_ptr
    assert_equal 1, root.r_ptr
    assert_equal "test root", root.name
  end

  test "test add_child should create child node" do
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

  test "test add_child should create child node under given parent" do
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

  test "test add_child should create child node under given parent, not affecting others" do
    root = TestTree.create_tree({name: "test root"})
    child = root.add_child({name: "test child"})
    grand_child = child.add_child({name: "test grand child"})
    child_out_of_scope = root.add_child({name: "test child out of scope"})

    # must update variables
    root = TestTree.find_by(id: root.id)
    child = TestTree.find_by(id: child.id)
    child_out_of_scope = TestTree.find_by(id: child_out_of_scope.id)

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

  test "test add_parent should create parent over given children" do
    root = TestTree.create_tree({name: "test root"})
    child = root.add_child({name: "test child"})
    grand_child = child.add_child({name: "test grand child"})
    child_out_of_scope = root.add_child({name: "test child out of scope"})

    # add parent over child
    parent = TestTree.add_parent([child], {name: "parent of child"})

    # must update variables
    root = TestTree.find_by(id: root.id)
    child = TestTree.find_by(id: child.id)
    grand_child = TestTree.find_by(id: grand_child.id)
    child_out_of_scope = TestTree.find_by(id: child_out_of_scope.id)

    assert_equal 0, root.l_ptr
    assert_equal 9, root.r_ptr
    assert_equal "test root", root.name
    assert_equal 1, parent.l_ptr
    assert_equal 6, parent.r_ptr
    assert_equal "parent of child", parent.name
    assert_equal 2, child.l_ptr
    assert_equal 5, child.r_ptr
    assert_equal "test child", child.name
    assert_equal 3, grand_child.l_ptr
    assert_equal 4, grand_child.r_ptr
    assert_equal 7, child_out_of_scope.l_ptr
    assert_equal 8, child_out_of_scope.r_ptr
    assert_equal "test child out of scope", child_out_of_scope.name
  end

end