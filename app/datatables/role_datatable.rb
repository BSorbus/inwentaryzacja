class RoleDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegators :@view, :link_to, :role_path

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:         { source: "Role.id", cond: :eq, searchable: false, orderable: false },
      name:       { source: "Role.name", cond: :like, searchable: true, orderable: true },
      note:       { source: "Role.note", cond: :like, searchable: true, orderable: true },
      activities: { source: "Role.activities", cond: :like, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |record|
      {
        id:         record.id,
        name:       link_to( record.fullname, role_path(record.id) ),
        note:       record.note_truncate,
        activities: record.try(:activities)
      }
    end
  end

  private

    def get_raw_records
      Role.distinct
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
