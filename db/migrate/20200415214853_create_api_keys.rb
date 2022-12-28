class CreateApiKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.string :name
      t.string :password
      t.string :access_token

      t.timestamps
    end
    add_index :api_keys, [:name], unique: true
  end
end
