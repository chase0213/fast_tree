module FastTree
  module Model
    extend ActiveSupport::Concern

    # class methods
    module ClassMethods
      def create_tree attributes={}
        unless self.exists?("l_ptr >= 0 OR r_ptr >= 0")
          attributes[:l_ptr] = 0
          attributes[:r_ptr] = 1
          self.create(attributes)
        else
          self.find_by(l_ptr: 0)
        end
      end

      def add_parent children, attributes={}
        l_ptr = children.max {|c| c.l_ptr}.l_ptr
        r_ptr = children.min {|c| c.r_ptr}.r_ptr + 1

        # parent node's pointer
        attributes[:l_ptr] = l_ptr
        attributes[:r_ptr] = r_ptr

        nodes_under = self.where("l_ptr > ? AND r_ptr < ?", l_ptr, r_ptr).order(r_ptr: :desc)
        nodes_on_right = self.where("l_ptr < ? AND r_ptr >= ?", r_ptr, r_ptr).order(r_ptr: :desc)

        # update nodes on the right of the target
        nodes_on_right.each do |node|
          node.l_ptr = node.l_ptr + 2
          node.r_ptr = node.r_ptr + 2
          node.save
        end

        # update nodes under the target
        nodes_under.each do |node|
          node.r_ptr = node.r_ptr + 2
          node.save
        end

        # create parent over children
        self.class.create(attributes)
      end


    end

    def add_child attributes={}
      # NOTE:
      # Do NOT use 'self.r_ptr' since attributes of 'self' may not be updated
      r_ptr = self.class.find(self.id).r_ptr

      # child node's pointer
      attributes[:l_ptr] = r_ptr
      attributes[:r_ptr] = r_ptr + 1

      nodes_on_right = self.class.where("l_ptr >= ?", r_ptr).order(r_ptr: :desc)
      parents = self.class.where("l_ptr < ? AND r_ptr >= ?", r_ptr, r_ptr).order(r_ptr: :desc)

      nodes_on_right.each do |node|
        node.l_ptr = node.l_ptr + 2
        node.r_ptr = node.r_ptr + 2
        node.save
      end

      parents.each do |parent|
        parent.r_ptr = parent.r_ptr + 2
        parent.save
      end

      # create child
      self.class.create(attributes)
    end

    def remove node
    end

    def copy root_from, parent_to
    end

    def move root_from, parent_to
    end

    def swap root_a, root_b
    end

  end
end