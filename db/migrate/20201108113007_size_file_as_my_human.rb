require 'my_human'

class SizeFileAsMyHuman < ActiveRecord::Migration[5.2]
  include ActionView::Helpers::NumberHelper

  def up
    Component.where.not(component_file: nil).each do |rec|
      rec.update_columns(file_size: MyHuman.new.filesize(rec.component_file.file.size) )
    end
  end

  def down
    Component.where.not(component_file: nil).each do |rec|
      rec.update_columns(file_size: number_to_human_size(rec.component_file.file.size, options = {}) )
    end
  end
end
