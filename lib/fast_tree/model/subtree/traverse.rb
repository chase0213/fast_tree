module FastTree
  module Model
    module Subtree
      module Traverse
        extend ActiveSupport::Concern

        included do
          scope :bfs, -> { order(depth: :asc, l_ptr: :asc) }
          scope :dfs, -> { order(l_ptr: :asc) }
        end

        def subtree
          self.class.where(self.class.arel_table[:l_ptr].gteq(l_ptr))
                    .where(self.class.arel_table[:r_ptr].lteq(r_ptr))
        end

      end
    end
  end
end