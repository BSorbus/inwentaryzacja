class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :wso2is_userid
      t.string :email, null: false
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :user_name
      t.boolean :csu_confirmed
      t.datetime :csu_confirmed_at
      t.string :csu_confirmed_by
      ## SAML
      t.string :session_index, index: true

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.text :note, default: ""
      t.references :author, foreign_key: false, index: true, type: :uuid

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
