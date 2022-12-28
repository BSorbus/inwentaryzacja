module GroupsHelper

  ICON = "user-friends"

  def group_icon_legend
    fa_icon(ICON)
  end

  def group_legend
    fa_icon(ICON, text: t("groups.show.title"))
  end

  def group_show_legend
    fa_icon(ICON, text: t("groups.show.title"))
  end

  def group_index_legend
    fa_icon(ICON, text: t("groups.index.title"))
  end

  def group_edit_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("groups.edit.title") + ": " + data_obj.fullname_was) : fa_icon(ICON, text: t("helpers.links.edit") )
  end

  def group_new_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("groups.new.title") + ": " + data_obj.fullname) : fa_icon(ICON, text: t("helpers.links.new") )
  end

  def group_new_edit_legend(data_obj)
    data_obj.new_record? ? group_new_legend(data_obj) :  group_edit_legend(data_obj)
  end

  def group_info_legend(data_obj)
    group_show_legend + ": " + data_obj.fullname
  end

end
