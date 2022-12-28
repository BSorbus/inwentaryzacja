class CreateArchives < ActiveRecord::Migration[5.2]
  def change
    create_table :archives, id: :uuid do |t|
      t.string :name
      t.date :expiry_on, index: true
      t.text :note, default: ""
      t.bigint :quota, default: 1073741824
      t.references :author, foreign_key: { to_table: :users }, index: true, type: :uuid

      t.timestamps
    end

    add_index :archives, :name, unique: true
  end
end
