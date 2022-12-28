module UsersHelper

  ICON = "user"

  def user_icon_legend
    fa_icon(ICON)
  end

  def user_legend
    fa_icon(ICON, text: t("users.show.title"))
  end

  def user_show_legend
    fa_icon(ICON, text: t("users.show.title"))
  end

  def user_index_legend
    fa_icon(ICON, text: t("users.index.title"))
  end

  def user_edit_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("users.edit.title") + ": " + data_obj.fullname_was) : fa_icon(ICON, text: t("helpers.links.edit") )
  end

  def user_new_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("users.new.title") + ": " + data_obj.fullname) : fa_icon(ICON, text: t("helpers.links.new") )
  end

  def user_info_legend(data_obj)
    user_show_legend + ": " + data_obj.fullname
  end

end
