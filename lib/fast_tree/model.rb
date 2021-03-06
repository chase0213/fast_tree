module FastTree
  module Model
    extend ActiveSupport::Concern

    included do
      include FastTree::Model::Subtree::Traverse
    end


    # =================
    # Class Methods
    # =================

    module ClassMethods

      # ====================
      # structure operation
      # ====================

      def add_parent(parent, children, &block)
        parent_depth = children.first.depth

        # create space for parent
        ptrs = _create_parent_embedded_space(children)

        # parent node's pointer
        parent.l_ptr = ptrs[:l_ptr]
        parent.r_ptr = ptrs[:r_ptr]
        parent.depth = parent_depth
        parent.save
      end

      def create_parent(attributes = {}, children, &block)
        parent_depth = children.first.depth

        # create space for parent
        ptrs = _create_parent_embedded_space(children)

        # parent node's pointer
        attributes[:l_ptr] = ptrs[:l_ptr]
        attributes[:r_ptr] = ptrs[:r_ptr]
        attributes[:depth] = parent_depth

        self.create(attributes, &block)
      end

      def create_tree(attributes={}, &block)
        root = self.find_root
        if root
          root
        else
          attributes[:l_ptr] = 0
          attributes[:r_ptr] = 1
          attributes[:depth] = 0
          self.create(attributes, &block)
        end
      end


      def _create_parent_embedded_space(children)
        left  = children.max {|c| c.l_ptr}.l_ptr
        right = children.min {|c| c.r_ptr}.r_ptr

        sql = <<-"EOS"
UPDATE #{self.to_s.underscore.pluralize}
  SET l_ptr = CASE
                WHEN l_ptr >= #{left}
                  AND r_ptr <= #{right}
                  THEN l_ptr + 1
                WHEN l_ptr > #{right}
                  THEN l_ptr + 2
                ELSE l_ptr
                END,
      r_ptr = CASE
                WHEN l_ptr >= #{left}
                  AND r_ptr <= #{right}
                  THEN r_ptr + 1
                WHEN l_ptr < #{left}
                  AND r_ptr > #{right}
                  THEN r_ptr + 2
                WHEN l_ptr > #{right}
                  THEN r_ptr + 2
                ELSE r_ptr
              END,
      depth = CASE
                WHEN l_ptr >= #{left}
                  AND r_ptr <= #{right}
                  THEN depth + 1
                ELSE depth
              END
  WHERE r_ptr > #{left}
        EOS

        ActiveRecord::Base.connection.execute(sql)

        # return left and right pointers between which parent is embedded
        {l_ptr: left, r_ptr: right + 2}
      end

      # ================
      # model operation
      # ================

      def find_root
        self.find_by(l_ptr: 0)
      end

      def find_subtree_by_root(node)
        l_ptr = node.l_ptr
        r_ptr = node.r_ptr

        self.where(self.arel_table[:l_ptr].gteq(l_ptr))
            .where(self.arel_table[:r_ptr].lteq(r_ptr))
      end

      # ================
      # for debugging
      # ================

      def print_subtree(root)
        puts("printing sub tree for #{root.name}...")
        subtree = find_subtree_by_root(root)
        subtree.order(l_ptr: :asc).each do |st_node|
          st_node.reload
          # white spaces on the left
          wsl = st_node.l_ptr.times.map{|s| "_"}.join('')
          # arrows
          ars = (st_node.r_ptr - st_node.l_ptr ).times.map{|s| "-"}.join('')
          # white spaces on the right
          wsr = (root.width + 2 - wsl.size - ars.size).times.map{|s| " "}.join('')

          puts("#{wsl}<#{ars}>#{wsr} ... #{st_node.name}")
        end
        puts("done.\n")
      end
    end


    #     class methods
    # =========================================================
    #    instance methods


    # =================
    # Instance Methods
    # =================

    def add_child(node)
      # bulk update nodes by a sql query
      _update_nodes(r_ptr, r_ptr, "r_ptr >= #{r_ptr}")

      # child node's pointer
      node.l_ptr = r_ptr
      node.r_ptr = r_ptr + 1
      node.depth = depth + 1
      node.save
    end

    def create_child(attributes = {}, &block)
      # bulk update nodes by a sql query
      _update_nodes(r_ptr, r_ptr, "r_ptr >= #{r_ptr}")

      # create child
      attributes[:l_ptr] = r_ptr
      attributes[:r_ptr] = r_ptr + 1
      attributes[:depth] = depth + 1
      self.class.create(attributes, &block)
    end

    def copy_to(node)
      # create empty space into which subtree embedded
      _update_nodes(node.l_ptr, node.r_ptr, "r_ptr >= #{node.r_ptr}", width + 1)

      # self and node may be updated by shifting
      self.reload
      node.reload

      bias = node.r_ptr - r_ptr - 1
      base_depth = depth
      self.subtree.each do |st_node|
        attributes = st_node.attributes.to_h
        attributes.delete("id")
        attributes["l_ptr"] += bias
        attributes["r_ptr"] += bias
        attributes["depth"] += node.depth - base_depth + 1
        self.class.create(attributes)
      end
    end

    def move_to(node)
      # NOTE:
      # copy_to and remove change node ids
      # move operation should change nothing but left and right pointers

      # create empty spaces under the node
      _update_nodes(node.r_ptr, node.r_ptr, "r_ptr >= #{node.r_ptr}", width + 1)

      self.reload
      node.reload

      # remember where the node were
      empty_space_left = self.l_ptr
      empty_space_right = self.r_ptr

      # move subtree under the given node
      bias = node.r_ptr - r_ptr - 1
      base_depth = depth
      self.subtree.each do |st_node|
        st_node.l_ptr += bias
        st_node.r_ptr += bias
        st_node.depth += node.depth - base_depth + 1
        st_node.save
      end

      self.reload
      node.reload

      # fill (virtual) empty spaces that will be created by moving subtree
      _update_nodes(empty_space_left, empty_space_right, "r_ptr > #{empty_space_right}", - (width + 1))
    end

    def remove
      # remove subtree
      n_destroyed = self.class.find_subtree_by_root(self).destroy_all

      # fill empty space
      _update_nodes(l_ptr, r_ptr, "r_ptr >= #{r_ptr}", - (width + 1))

      # return count of destroyed nodes
      n_destroyed
    end

    def path
      self.class.where(self.class.arel_table[:l_ptr].lteq(l_ptr))
                .where(self.class.arel_table[:r_ptr].gteq(r_ptr))
                .order(l_ptr: :asc)
    end

    def print_subtree
      self.class.print_subtree(self)
    end

    def width
      r_ptr - l_ptr
    end


    #
    # Boolean Methods
    #

    def root?
      self.l_ptr == 0
    end

    def leaf?
      l_ptr == r_ptr - 1
    end

    def has_children?
      l_ptr != r_ptr - 1
    end

    #
    # Getter Methods
    #

    def parent
      self.class.where(self.class.arel_table[:l_ptr].lt(l_ptr))
                .where(self.class.arel_table[:r_ptr].gt(r_ptr))
                .where(depth: depth - 1)
                .try(:first)
    end

    def children
      self.class.where(self.class.arel_table[:l_ptr].gt(l_ptr))
                .where(self.class.arel_table[:r_ptr].lt(r_ptr))
                .where(depth: depth + 1)
    end


    protected

      def _update_nodes(left, right, condition, diff = 2)
        #
        # Possible patterns
        #
        #     left         right
        # --------------------------
        # <---> |            |         ... 1.
        #     <----->        |         ... 2.
        #       |  <----->   |         ... 3.
        #       |         <----->      ... 4.
        #       |            | <---->  ... 5.
        #   <------------------->      ... 6.
        #       |            |
        #
        #
        # 1: do nothing
        #   l_ptr <- l_ptr
        #   r_ptr <- r_ptr
        #
        # 2: do nothing (illegal node)
        #   l_ptr <- l_ptr
        #   r_ptr <- r_ptr
        #
        # 3: move diff - 1 to the right
        #   l_ptr <- l_ptr + diff - 1
        #   r_ptr <- r_ptr + diff - 1
        #
        # 4: do nothing (illegal node)
        #   l_ptr <- l_ptr
        #   r_ptr <- r_ptr
        #
        # 5: move diff to the right
        #   l_ptr <- l_ptr + diff
        #   r_ptr <- r_ptr + diff
        #
        # 6: move right endpoint by diff to the right
        #   l_ptr <- l_ptr
        #   r_ptr <- r_ptr + diff
        #

        #
        # NOTE:
        # Due to performance reason,
        # use raw SQL query to move nodes
        #

        sql = <<-"EOS"
UPDATE #{self.class.to_s.underscore.pluralize}
SET l_ptr = CASE
              WHEN l_ptr > #{right}
                THEN l_ptr + #{diff}
              WHEN l_ptr > #{left}
                AND r_ptr < #{right}
                THEN l_ptr + #{diff - 1}
              ELSE l_ptr
            END,
    r_ptr = CASE
              WHEN l_ptr <= #{left}
                AND r_ptr >= #{right}
                THEN r_ptr + #{diff}
              WHEN l_ptr > #{right}
                THEN r_ptr + #{diff}
              WHEN l_ptr > #{left}
                AND r_ptr < #{right}
                THEN r_ptr + #{diff - 1}
              ELSE
                r_ptr
            END
WHERE #{condition}
        EOS

        ActiveRecord::Base.connection.execute(sql)
      end

      class InvalidTreeStructureError < ActiveRecord::RecordInvalid; end

  end
end