class CreateTestDefaultTrees < ActiveRecord::Migration[5.0]
  def change
    create_table :test_default_trees do |t|

      t.timestamps
    end
  end
end
