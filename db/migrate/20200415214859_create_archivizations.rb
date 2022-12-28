class CreateArchivizations < ActiveRecord::Migration[5.2]
  def change
    create_table :archivizations, id: :uuid do |t|
      t.references :archive, foreign_key: { to_table: :archives }, index: true, type: :uuid
      t.references :group, foreign_key: { to_table: :groups }, index: true, type: :uuid
      t.references :archivization_type, foreign_key: { to_table: :archivization_types }, index: true

      t.timestamps      
    end
    
    add_index :archivizations, [:archive_id, :group_id, :archivization_type_id], unique: true, name: "archivizations_archive_id_group_id_archivization_type_id_idx"
  end
end
