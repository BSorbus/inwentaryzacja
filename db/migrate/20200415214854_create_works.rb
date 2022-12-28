class CreateWorks < ActiveRecord::Migration[5.2]
  def change
    create_table :works, id: :uuid do |t|
      t.references :trackable, polymorphic: true, index: true, type: :uuid
      t.references :author, foreign_key: { to_table: :users }, index: true, type: :uuid
      t.string :action
      t.string :url
      t.text :parameters

      t.timestamps
    end
  end
end
