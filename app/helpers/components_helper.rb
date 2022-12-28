module ComponentsHelper

  ICON = "paperclip"
  ICON_FOLDER = "folder"

  def component_icon_legend
    fa_icon(ICON)
  end

  def component_legend
    fa_icon(ICON, text: t("components.index.title"))
  end

  def component_index_legend
    fa_icon(ICON, text: t("components.index.title"))
  end

  def component_edit_legend(data_obj)
    # fa_icon(ICON, text: t("component.edit.title") + ": " + data_obj.fullname )
    data_obj.is_file? ? fa_icon(ICON, text: t("components.edit.title") + ": " + data_obj.name_was ) : fa_icon(ICON_FOLDER, text: t("components.edit.title") + ": " + data_obj.name_was )
  end

  def component_new_legend(data_obj)
    fa_icon(ICON, text: t("components.new.title"))
  end

  def component_new_edit_legend(data_obj)
    data_obj.new_record? ? component_new_legend(data_obj) :  component_edit_legend(data_obj)
  end

end
