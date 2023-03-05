require 'my_human'

class ComponentDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegators :@view, :link_to, :edit_component_path, :edit_component_path, :component_path, :download_component_path, :t, :fa_icon, :number_to_human_size, :to_s

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:             { source: "Component.id", cond: :eq, searchable: false, orderable: false },
      name_if_folder: { source: "Component.name_if_folder", cond: :eq, searchable: false, orderable: false },
      name:           { source: "Component.name", cond: :like, searchable: true, orderable: true },
      note:           { source: "Component.note",  cond: :like, searchable: true, orderable: true },
      author:         { source: "User.email",  cond: :like, searchable: true, orderable: true },
      updated_at:     { source: "Component.updated_at",  cond: :like, searchable: true, orderable: true },
      file_size:      { source: "Component.file_size",  cond: :like, searchable: false, orderable: false },
      action:         { source: "Component.id",  cond: :like, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      {
        id:             record.id,
        name_if_folder: record.name_if_folder.present? ? record.name_if_folder : '',
        name:           link_component_file_or_folder(record).html_safe,
        note:           record.note_truncate,
        file_size:      file_size_or_sum_files_size_and_badge(record).html_safe,
        author:         record.author.fullname,
        updated_at:     record.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
        action:         action_links(record).html_safe
      }
    end
  end

  private

  def get_raw_records
    if (options[:componentable_id]).present? && (options[:componentable_type]).present?
      #data = Component.joins(:user).where(componentable_id: options[:componentable_id], componentable_type: options[:componentable_type]).order(:name_if_folder)
      data = Component.joins(:author).where(componentable_id: options[:componentable_id], componentable_type: options[:componentable_type]).order('components.name_if_folder')
    else
      data = Component.joins(:author)
    end

    if options[:component_parent_filter].present? 
      data.only_for_parent(options[:component_parent_filter]).with_ancestor 
    else
      data.with_ancestor.roots
    end

  end

  def link_component_file_or_folder(rec)
    if rec.is_folder?
      #rec.name_if_folder == rec.name
      breadcrumb_data = JSON.generate( {parent_id: rec.id, 
                                        ancestry_path: rec.ancestry_path,
                                        ancestor_ids: rec.ancestor_ids } )

      fa_icon("folder" ) + link_to( ' ' + rec.name, '#', onclick: "linkToComponentBreadcrumb( #{breadcrumb_data} )", remote: true)
      # link_to( rec.name, '#', onclick: "linkToComponentBreadcrumb( #{breadcrumb_data} )", remote: true, class: 'fa fa-folder', title: "Podgląd", rel: 'tooltip')
      # link_to "#{'<strong>'+rec.name+'</strong>'}", "#", onclick: "linkToComponentBreadcrumb( #{breadcrumb_data} )", remote: true
      # link_to fa_icon("folder", text: rec.name ), "javascript:linkToComponentBreadcrumb( #{breadcrumb_data} );return false;"
    else
      rec.name
    end
  end

  def link_show(rec)
    "<button-as-link ajax-path='" + component_path(rec, format: :js) + "' ajax-method='GET' class='btn btn-xs fa fa-share-alt text-primary' title='" + t('tooltip.show') + "' rel='tooltip'></button-as-link>"
  end

  def link_edit(rec)
#    link_to(' ', @view.edit_component_path(rec.id), class: 'fa fa-edit', title: "Edycja", rel: 'tooltip')
#    link_to(' ', @view.edit_component_path(rec.id), class: 'fa fa-edit', remote: true, title: "Edycja", rel: 'tooltip')
     "<button-as-link ajax-path='" + edit_component_path(rec, format: :js) + "' ajax-method='GET' class='btn btn-xs fa fa-edit text-primary' title='" + t('tooltip.edit') + "' rel='tooltip'></button-as-link>"
  end

  def link_download(rec)
    "<button-as-link ajax-path='" + download_component_path(rec, format: :js) + "' ajax-method='GET' class='btn btn-xs fa fa-download text-primary' title='" + t('tooltip.download') + "' rel='tooltip'></button-as-link>"
  end

  def link_destroy(rec)
    "<button-as-link ajax-path='" + component_path(rec) + "' ajax-method='DELETE' class='btn btn-xs fa fa-trash text-danger' title='" + t('tooltip.destroy') + "' rel='tooltip'></button-as-link>"
  end

  def file_size_or_sum_files_size_and_badge(rec)
    if rec.is_folder?
      badge(rec)
    else
      "<div>#{rec.file_size}</div>"
    end
  end

  def badge(rec)
    count = rec.leaves.where.not(component_file: nil).size
    sum_size = rec.leaves.where.not(component_file: nil).map {|a| a.component_file.file.size }.sum
#    count > 0 ? "<div> #{number_to_human_size(sum_size)} <span class='badge alert-info pull-right'> #{count} </span></div>" : "<div></div>"
    count > 0 ? "<div> #{MyHuman.new.filesize(sum_size)} <span class='badge alert-info pull-right'> #{count} </span></div>" : "<div></div>"
  end

  def action_links(rec)
    if rec.is_folder?
      "<div style='text-align: center'>" +
        link_edit(rec) + 
        link_destroy(rec) +
      "</div>"
    else
      "<div style='text-align: center'>" +
        link_download(rec) +
        # link_show(rec) +
        link_edit(rec) +
        link_destroy(rec) +
      "</div>"
    end
  end

 

  # ==== These methods represent the basic operations to perform on records


  # def sort_records(records)
  #   sort_by = datatable.orders.inject([]) do |queries, order|
  #     column = order.column
  #     queries << order.query(column.sort_query) if column && column.orderable?
  #     queries
  #   end
  #   records.order(Arel.sql(sort_by.join(', ')))
  # end

  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary
end
