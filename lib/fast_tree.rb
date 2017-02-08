require 'rails'


module FastTree
  autoload :Model, 'fast_tree/model'

  module Model
    module Subtree
      autoload :Traverse, 'fast_tree/model/subtree/traverse'
    end
  end

end
