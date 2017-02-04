module FastTree
  module Model
    extend ActiveSupport::Concern

    # class methods
    module ClassMethods

      def add_parent children, attributes={}
        left  = children.max {|c| c.l_ptr}.l_ptr
        right = children.min {|c| c.r_ptr}.r_ptr

        # parent node's pointer
        attributes[:l_ptr] = left
        attributes[:r_ptr] = right + 2

        nodes = self.where(self.arel_table[:r_ptr].gt(left))

        # update nodes
        nodes.each do |node|
          # In this method, the entity substitued by this model may be changed
          node.reload

          if node.l_ptr >= left and node.r_ptr <= right
            #
            #      <------->
            #    <----------->  : parent
            #
            node.l_ptr += 1
            node.r_ptr += 1

          elsif node.l_ptr < left and node.r_ptr > right
            #  <--------------->
            #    <----------->  : parent
            node.r_ptr += 2

          elsif node.l_ptr > right
            #                   <------>
            #    <----------->  : parent
            node.l_ptr += 2
            node.r_ptr += 2

          else
            raise FastTree::Model::InvalidTreeStructureError
          end

          node.save
        end

        # create parent over children
        self.create(attributes)
      end

      def create_tree attributes={}
        root = self.find_root
        if root
          root
        else
          attributes[:l_ptr] = 0
          attributes[:r_ptr] = 1
          self.create(attributes)
        end
      end

      def find_root
        self.find_by(l_ptr: 0)
      end

      def find_subtree_by_root node
        l_ptr = node.l_ptr
        r_ptr = node.r_ptr

        self.where(self.arel_table[:l_ptr].gteq(l_ptr))
            .where(self.arel_table[:r_ptr].lteq(r_ptr))
      end

      def print_subtree root
        puts("printing sub tree for #{root.name}...")
        subtree = find_subtree_by_root(root)
        subtree.order(l_ptr: :asc).each do |st_node|
          st_node.reload
          # white spaces on the left
          wsl = st_node.l_ptr.times.map{|s| "_"}.join('')
          # arrows
          ars = (st_node.r_ptr - st_node.l_ptr ).times.map{|s| "-"}.join('')
          # white spaces on the right
          wsr = (root.width + 3 - wsl.size - ars.size).times.map{|s| " "}.join('')

          puts("#{wsl}<#{ars}>#{wsr} ... #{st_node.name}")
        end
        puts("done.\n")
      end

    end

    def add_child attributes={}
      # In this method, the entity substitued by this model may be changed
      self.reload

      # child node's pointer
      attributes[:l_ptr] = r_ptr
      attributes[:r_ptr] = r_ptr + 1

      nodes = self.class.where(self.class.arel_table[:r_ptr].gteq(r_ptr))
      update_nodes(nodes, r_ptr, r_ptr)

      # create child
      self.class.create(attributes)
    end

    def remove
      # remove subtree
      n_destroyed = self.class.find_subtree_by_root(self).destroy_all

      # fill empty space
      nodes = self.class.where(self.class.arel_table[:r_ptr].gteq(r_ptr))
      update_nodes(nodes, l_ptr, r_ptr, - width)

      # return count of destroyed nodes
      n_destroyed
    end

    def copy_to node
      subtree = self.class.find_subtree_by_root(self)

      # create empty space into which subtree embedded
      nodes = self.class.where(self.class.arel_table[:r_ptr].gteq(node.l_ptr))
      update_nodes(nodes, node.l_ptr, node.r_ptr, width)

      bias = node.l_ptr + 1 - l_ptr
      subtree.each do |st_node|
        attributes = st_node.attributes.to_h
        attributes.delete("id")
        attributes["l_ptr"] = attributes["l_ptr"] + bias
        attributes["r_ptr"] = attributes["r_ptr"] + bias
        self.class.create(attributes)
      end
    end

    def move_to node
      # NOTE:
      # copy_to and remove change node ids
      # move operation should change nothing but left and right pointers

      # bind subtree to a variable
      subtree = self.class.find_subtree_by_root(self)

      # fill (virtual) empty spaces that will be created by moving subtree
      nodes = self.class.where(self.class.arel_table[:l_ptr].gt(r_ptr))
      update_nodes(nodes, l_ptr, r_ptr, - width)

      # create empty spaces under the node
      node.reload
      nodes = self.class.where(self.class.arel_table[:l_ptr].gteq(node.l_ptr))
                        .where(self.class.arel_table[:r_ptr].lteq(node.r_ptr))
      update_nodes(nodes, node.l_ptr, node.r_ptr, width)

      # move subtree under the given node
      bias = node.l_ptr + 1 - l_ptr
      subtree.each do |st_node|
        st_node.l_ptr += bias
        st_node.r_ptr += bias
        st_node.save
      end
    end

    def width
      r_ptr - l_ptr + 1
    end

    def height
    end

    def print_subtree
      self.class.print_subtree(self)
    end

    protected

      def update_nodes nodes, left, right, diff=2
        # update nodes

        nodes.each do |node|
          # In this method, the entity substitued by this model may be changed
          node.reload

          if node.l_ptr <= left and node.r_ptr >= right
            #
            #  <--------------->  ... node
            #    <----------->
            #    |           |
            #    +- left     +- right
            #
            node.r_ptr += diff

          elsif node.l_ptr > right
            #
            #                   <------>  ... node
            #    <----------->
            #    |           |
            #    +- left     +- right
            #
            node.l_ptr += diff
            node.r_ptr += diff

          elsif node.l_ptr > left and node.r_ptr < right
            #
            #      <------->    ... node
            #    <----------->
            #    |           |
            #    +- left     +- right
            #
            node.l_ptr += diff - 1
            node.r_ptr += diff - 1

          else
          end

          node.save
        end
      end

      class InvalidTreeStructureError < ActiveRecord::RecordInvalid; end

  end
end