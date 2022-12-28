class CreateApprovals < ActiveRecord::Migration[5.2]
  def change
    create_table :approvals do |t|
      t.references :role, foreign_key: { to_table: :roles }, index: true, type: :uuid
      t.references :user, foreign_key: { to_table: :users }, index: true, type: :uuid
      t.references :author, foreign_key: { to_table: :users }, index: true, type: :uuid

      t.timestamps
    end
    add_index :approvals, [:role_id, :user_id], unique: true
  end
end
