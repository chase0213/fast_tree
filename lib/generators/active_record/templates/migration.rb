class FastTreeCreate<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :<%= table_name %> do |t|
<%= migration_data -%>

<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>

      t.timestamps null: false
    end

    add_index :<%= table_name %>, :l_ptr, unique: true
    add_index :<%= table_name %>, :r_ptr, unique: true
  end
end