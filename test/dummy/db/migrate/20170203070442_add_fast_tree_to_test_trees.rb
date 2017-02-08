class AddFastTreeToTestTrees < ActiveRecord::Migration[5.0]
  def self.up
    change_table :test_trees do |t|
      ## Pointers
      t.integer :l_ptr
      t.integer :r_ptr
      t.integer :depth

    end

    add_index :test_trees, :l_ptr
    add_index :test_trees, :r_ptr
    add_index :test_trees, :depth
  end

  def self.down
    # model already existed. Please edit below which fields you would like to remove in this migration.
  end
end
