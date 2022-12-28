class GroupArchivesDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegators :@view, :link_to, :archive_path

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:             { source: "Archive.id", cond: :eq, searchable: false, orderable: false },
      name:           { source: "Archive.name", cond: :like, searchable: true, orderable: true },
      expiry_on:      { source: "Archive.expiry_on", cond: :like, searchable: true, orderable: true },
      note:           { source: "Archive.note", cond: :like, searchable: true, orderable: true },
      archivizations: { source: "Archive.id",  searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      {
        id:             record.id,
        name:           link_to( record.fullname, archive_path(record.id) ),
        expiry_on:      record.expiry_on.present? ? record.expiry_on.strftime("%Y-%m-%d") : '' ,
        note:           record.note_truncate,
        archivizations: record.archivizations.where(group_id: options[:only_for_current_group_id]).map {|row| "#{row.archivization_type.try(:name)}" }.join('<br>').html_safe
      }
    end
  end

  private

    def get_raw_records
      if options[:checked_only_filter].present?
        Group.find(options[:only_for_current_group_id]).accesses_archives.distinct
      else
        Archive.all
      end
    end



  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary
end
