require 'rails/generators/named_base'

module FastTree
  module Generators
    class FastTreeGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      namespace "fast_tree"
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a model with the given NAME (if one does not exist) with a migration file"

      hook_for :orm
    end
  end
end