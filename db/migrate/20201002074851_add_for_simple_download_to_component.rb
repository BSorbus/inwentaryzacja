class AddForSimpleDownloadToComponent < ActiveRecord::Migration[5.2]
  def change
    add_column :components, :for_simple_download, :uuid, index: true, default: "gen_random_uuid()"
  end
end
