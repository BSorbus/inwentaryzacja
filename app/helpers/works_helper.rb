module WorksHelper

  ICON = "history"

  def work_icon_legend
    fa_icon(ICON)
  end

  def work_index_legend
    fa_icon(ICON, text: t("works.index.title"))
  end

end