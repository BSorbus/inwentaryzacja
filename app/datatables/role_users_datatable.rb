class RoleUsersDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegators :@view, :link_to, :user_path, :role_user_path, :role_users_path, :policy

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:         { source: "User.id", cond: :eq, searchable: false, orderable: false },
      email:      { source: "User.email", cond: :like, searchable: true, orderable: true },
      last_name:  { source: "User.last_name", cond: :like, searchable: true, orderable: true },
      first_name: { source: "User.first_name", cond: :like, searchable: true, orderable: true },
      note:       { source: "User.note", cond: :like, searchable: true, orderable: true },
      has_role:   { source: "User.id",  searchable: false, orderable: false },
      action:     { source: "User.id", searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      role_has_user = Role.joins(:users).where(users: {id: record.id}, roles: {id: options[:only_for_current_role_id]}).any?
      {
        id:         record.id,
        email:      link_to( record.email, user_path(record.id) ),
        last_name:  link_last_name(record),
        first_name: link_first_name(record),
        note:       record.note_truncate,
        has_role:   role_has_user ? '<div style="text-align: center"><div class="fa fa-check"></div></div>'.html_safe : '',
        action:     link_add_remove(record, role_has_user).html_safe
      }
    end
  end

  private

    def get_raw_records
      if options[:checked_only_filter].present?
        Role.find(options[:only_for_current_role_id]).users
      else
        User.all
      end
    end

    def link_last_name(rec)
      rec.last_name_to_display.blank? ? "" : link_to( rec.last_name_to_display, user_path( rec.id) )
      # link_to(' ', @view.edit_attachment_path(rec.id), class: 'fa fa-edit', remote: true, title: "Edycja", rel: 'tooltip')
    end

    def link_first_name(rec)
      rec.first_name_to_display.blank? ? "" : link_to( rec.first_name_to_display, user_path( rec.id) )
    end

    def link_add_remove(rec, has_role)
      if policy(:role).add_remove_role_user?
        if has_role
          "<div style='text-align: center'><button ajax-path='" + role_user_path(role_id: options[:only_for_current_role_id], id: rec.id) + "' ajax-method='DELETE' toastr-message='" + rec.name + "<br>...usunięto' class='btn btn-xs btn-danger fa fa-minus'></button></div>"
        else
          "<div style='text-align: center'><button ajax-path='" + role_users_path(role_id: options[:only_for_current_role_id], id: rec.id) + "' ajax-method='POST' toastr-message='" + rec.name + "<br>...dodano' class='btn btn-xs btn-success fa fa-plus'></button></div>"
        end
      else
        ""
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
