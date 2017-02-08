class AddFastTreeTo<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def self.up
    change_table :<%= table_name %> do |t|
<%= migration_data -%>

<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
    end

    add_index :<%= table_name %>, :l_ptr
    add_index :<%= table_name %>, :r_ptr
    add_index :<%= table_name %>, :depth
  end

  def self.down
    # model already existed. Please edit below which fields you would like to remove in this migration.
  end
end