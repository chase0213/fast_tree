require 'rails/generators/active_record'
require 'generators/fast_tree/orm_helpers'

module ActiveRecord
  module Generators
    class FastTreeGenerator < ActiveRecord::Generators::Base
      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      include FastTree::Generators::OrmHelpers
      source_root File.expand_path("../templates", __FILE__)

      def copy_fast_tree_migration
        if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
          migration_template "migration_existing.rb", "db/migrate/add_fast_tree_to_#{table_name}.rb", migration_version: migration_version
        else
          migration_template "migration.rb", "db/migrate/fast_tree_create_#{table_name}.rb", migration_version: migration_version
        end
      end

      def generate_model
        invoke "active_record:model", [name], migration: false unless model_exists? && behavior == :invoke
      end

      def migration_data
<<RUBY
      ## Pointers
      t.integer :l_ptr
      t.integer :r_ptr
      t.integer :depth
RUBY
      end

      def rails5?
        Rails.version.start_with? '5'
      end

      def postgresql?
        config = ActiveRecord::Base.configurations[Rails.env]
        config && config['adapter'] == 'postgresql'
      end

     def migration_version
       if rails5?
         "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
       end
     end
    end
  end
end