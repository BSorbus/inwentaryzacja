class UserDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegators :@view, :link_to, :user_path

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:                   { source: "User.id", cond: :eq, searchable: false, orderable: false },
      email:                { source: "User.email", cond: :like, searchable: true, orderable: true },
      last_name:            { source: "User.last_name", cond: :like, searchable: true, orderable: true },
      first_name:           { source: "User.first_name", cond: :like, searchable: true, orderable: true },
      note:                 { source: "User.note", cond: :like, searchable: true, orderable: true },
      current_sign_in_ip:   { source: "User.current_sign_in_ip",  cond: :like, searchable: true, orderable: true },
      current_sign_in_at:   { source: "User.current_sign_in_at",  cond: :like, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |record|
      {
        id:                   record.id,
        email:                link_to( record.email, user_path(record.id) ),
        last_name:            link_last_name(record),
        first_name:           link_first_name(record),
        note:                 record.note_truncate,
        current_sign_in_ip:   record.current_sign_in_ip,
        current_sign_in_at:   record.current_sign_in_at.present? ? record.current_sign_in_at.strftime("%Y-%m-%d %H:%M:%S") : '' 
      }
    end
  end

  private

    def get_raw_records
      User.distinct
    end

    def link_last_name(rec)
      rec.last_name_to_display.blank? ? "" : link_to( rec.last_name_to_display, user_path( rec.id) )
      # link_to(' ', @view.edit_attachment_path(rec.id), class: 'fa fa-edit', remote: true, title: "Edycja", rel: 'tooltip')
    end

    def link_first_name(rec)
      rec.first_name_to_display.blank? ? "" : link_to( rec.first_name_to_display, user_path( rec.id) )
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
