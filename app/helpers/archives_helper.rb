require 'my_human'

module ArchivesHelper

  ICON = "archive"

  def archive_icon_legend
    fa_icon(ICON)
  end

  def archive_legend
    fa_icon(ICON, text: t("archives.show.title"))
  end

  def archive_show_legend
    fa_icon(ICON, text: t("archives.show.title"))
  end

  def archive_index_legend
    fa_icon(ICON, text: t("archives.index.title"))
  end

  def archive_edit_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("archives.edit.title") + ": " + data_obj.fullname_was) : fa_icon(ICON, text: t("helpers.links.edit") )
  end

  def archive_new_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("archives.new.title") + ": " + data_obj.fullname) : fa_icon(ICON, text: t("helpers.links.new") )
  end

  def archive_info_legend(data_obj)
    archive_show_legend + ": " + data_obj.fullname
  end

  def archive_human_size(data_size)
    MyHuman.new.filesize(data_size)
  end

end