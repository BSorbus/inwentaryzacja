module RolesHelper

  ICON = "user-tag"

  def role_icon_legend
    fa_icon(ICON)
  end

  def role_legend
    fa_icon(ICON, text: t("roles.show.title"))
  end

  def role_show_legend
    fa_icon(ICON, text: t("roles.show.title"))
  end

  def role_index_legend
    fa_icon(ICON, text: t("roles.index.title"))
  end

  def role_edit_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("roles.edit.title") + ": " + data_obj.fullname_was) : fa_icon(ICON, text: t("helpers.links.edit") )
  end

  def role_new_legend(data_obj=nil)
    data_obj.present? ? fa_icon(ICON, text: t("roles.new.title") + ": " + data_obj.fullname) : fa_icon(ICON, text: t("helpers.links.new") )
  end

  def role_info_legend(data_obj)
    role_show_legend + ": " + data_obj.fullname
  end

end
