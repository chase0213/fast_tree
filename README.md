# FastTree

[![CircleCI](https://circleci.com/gh/chase0213/fast_tree/tree/master.svg?style=svg)](https://circleci.com/gh/chase0213/fast_tree/tree/master)

Fast and Intuitive tree structure using nested sets model.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'fast_tree'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install fast_tree
```

## Usage

`fast_tree` provides a generator which adds left and right pointers used in nested sets model to your model class.
Even if you have created a class or not, execute following commands in the terminal:

```bash
$ bin/rails g fast_tree YOUR_MODEL_NAME
```

After executing the command, add the following line into your model:

```ruby
include FastTree::Model
```

It seems like:

```ruby
class YOUR_MODEL_NAME < ApplicationRecord
  include FastTree::Model

  ...
end
```

Finally, you can use several methods as class methods and instance methods.

If you are interested in how it works, see the section "How It Works" below.

### Create a tree

To initialize tree structure, do the following:

```ruby
attributes = { name: "root node" }
YOUR_MODEL_NAME.create_tree(attributes)
```

### Create or add child

To create a new leaf under a node,

```ruby
node = YOUR_MODEL_NAME.first

attributes = { name: "root node" }
node.create_child(attributes)
```

or, to add existed node to another,

```ruby
node = YOUR_MODEL_NAME.first

new_node = YOUR_MODEL_NAME.second
node.add_child(new_node)
```

### Create or add parent

To create a new parent over a node,

```ruby
node = YOUR_MODEL_NAME.first

attributes = { name: "root node" }
YOUR_MODEL_NAME.create_parent(attributes, [node])
```

or, to add existed node to another,

```ruby
node = YOUR_MODEL_NAME.first

parent = YOUR_MODEL_NAME.second
YOUR_MODEL_NAME.add_parent(parent, [node])
```

You can add/create a parent over several nodes:

```ruby
children = YOUR_MODEL_NAME.take(3)
parent = YOUR_MODEL_NAME.last
YOUR_MODEL_NAME.add_parent(parent, children)
```

NOTE: this method has a issue: https://github.com/chase0213/fast_tree/issues/6

### Remove a node

To remove a node reconstructing the tree,

```ruby
node = YOUR_MODEL_NAME.take
node.remove
```

If you don't want to reconstruct the tree after deleting a node, do the following:

```ruby
node = YOUR_MODEL_NAME.take
node.destroy
```

### Copy a subtree under a node

To copy a subtree under a node,

```ruby
root_of_subtree = YOUR_MODEL_NAME.first
target = YOUR_MODEL_NAME.second

root_of_subtree.copy_to(targe)
```

### Move a subtree under a node

To move a subtree under a node,

```ruby
root_of_subtree = YOUR_MODEL_NAME.first
target = YOUR_MODEL_NAME.second

root_of_subtree.move_to(targe)
```

### Find root

To get the root node from the tree,

```
root = YOUR_MODEL_NAME.find_root
```

### Deal with subtree

To get subtree from a root node,

```ruby
# root can be any node in the tree
root = YOUR_MODEL_NAME.take
root.subtree.each do |node|
  # do something
end
```

NOTE: `subtree` method returns ActiveRelation, so that you can use `each`, `map` or anything you want!

### Tree traverse algorithms

In `fast_tree`, several tree-traverse algorithms, such as DFS and BFS, are provided.

#### DFS (Depth First Search)

To get nodes by DFS,

```ruby
root = YOUR_MODEL_NAME.take
root.subtree.dfs.each do |node|
  # do something
end
```

#### BFS (Breadth First Search)

It'll be released in the next version!


## How It Works
The migration file will create a migration file, such as:

```ruby
class AddFastTreeToTestTrees < ActiveRecord::Migration[5.0]
  def self.up
    change_table :test_trees do |t|
      ## Pointers
      t.integer :l_ptr
      t.integer :r_ptr

    end

    add_index :test_trees, :l_ptr
    add_index :test_trees, :r_ptr
  end

  def self.down
    # model already existed. Please edit below which fields you would like to remove in this migration.
  end
end
```

, but you don't have to care what `l_ptr` and `r_ptr` are:
tree operations are executed in methods such as `create_child` or `remove`.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
