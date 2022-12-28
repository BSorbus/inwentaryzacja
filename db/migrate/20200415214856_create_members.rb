class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      t.references :group, foreign_key: { to_table: :groups }, index: true, type: :uuid
      t.references :user, foreign_key: { to_table: :users }, index: true, type: :uuid
      t.references :author, foreign_key: { to_table: :users }, index: true, type: :uuid

      t.timestamps
    end
    add_index :members, [:group_id, :user_id], unique: true
  end
end
