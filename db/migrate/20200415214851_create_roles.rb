class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name
      t.string :activities, array: true, using: 'gin', default: '{}'
      t.text :note, default: ""
      t.references :author, foreign_key: { to_table: :users }, index: true, type: :uuid

      t.timestamps
    end

    add_index :roles, :name, unique: true
  end
end
