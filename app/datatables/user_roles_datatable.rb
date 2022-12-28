class UserRolesDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegators :@view, :link_to, :role_path, :role_user_path, :role_users_path, :policy

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:         { source: "Role.id", cond: :eq, searchable: false, orderable: false },
      name:       { source: "Role.name", cond: :like, searchable: true, orderable: true },
      activities: { source: "Role.activities", cond: :like, searchable: true, orderable: true },
      has_role:   { source: "Role.id",  searchable: false, orderable: false },
      action:     { source: "Role.id", searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      user_has_role = User.joins(:roles).where(roles: {id: record.id}, users: {id: options[:only_for_current_user_id]}).any?
      {
        id:         record.id,
        name:       link_to( record.fullname, role_path(record.id) ),
        activities: record.try(:activities),
        has_role:   user_has_role ? '<div style="text-align: center"><div class="glyphicon glyphicon-ok"></div></div>'.html_safe : '',
        action:     link_add_remove(record, user_has_role).html_safe
      }
    end
  end

  private

    def get_raw_records
      if options[:checked_only_filter].present?
        User.find(options[:only_for_current_user_id]).roles
      else
        Role.all
      end
    end

    def link_add_remove(rec, has_role)
      if policy(rec).add_remove_role_user?
        if has_role
          "<div style='text-align: center'><button ajax-path='" + role_user_path(role_id: rec.id, id: options[:only_for_current_user_id]) + "' ajax-method='DELETE' toastr-message='" + rec.name + "<br>...usunięto' class='btn btn-xs btn-danger fa fa-minus'></button></div>"
        else
          "<div style='text-align: center'><button ajax-path='" + role_users_path(role_id: rec.id, id: options[:only_for_current_user_id]) + "' ajax-method='POST' toastr-message='" + rec.name + "<br>...dodano' class='btn btn-xs btn-success fa fa-plus'></button></div>"
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
