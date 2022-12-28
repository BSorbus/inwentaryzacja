class CreateComponentHierarchies < ActiveRecord::Migration[5.2]
  def change
    create_table :component_hierarchies, id: false do |t|
      t.uuid :ancestor_id, null: false
      t.uuid :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :component_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "component_anc_desc_idx"

    add_index :component_hierarchies, [:descendant_id],
      name: "component_desc_idx"
  end
end
