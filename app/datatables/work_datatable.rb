class WorkDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  include ActionView::Helpers::UrlHelper # for link_to
  include ActionView::Helpers::TextHelper

  def_delegators :@view, :link_to, :user_path

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      id:             { source: "Work.id", cond: :eq, searchable: false, orderable: false },
      created_at:     { source: "Work.created_at", cond: :like, searchable: true, orderable: true },
      created_by:     { source: "User.user_name",  cond: :like, searchable: true, orderable: true },
      action:         { source: "Work.action",  cond: :like, searchable: true, orderable: true },
      trackable_type: { source: "Work.trackable_type",  cond: :like, searchable: true, orderable: true },
      trackable_id:   { source: "Work.trackable_id",  cond: :like, searchable: true, orderable: true },
      parameters:     { source: "Work.parameters",  cond: :like, searchable: true, orderable: false }
    }
  end

  def data
    records.map do |record|
      {
        id:             record.id,
        created_at:     record.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        created_by:     record.author ? link_to( record.author.fullname, user_path(record.author_id) ) : record.author_id,
        action:         record.action,
        trackable_type: record.trackable_type,
        trackable_id:   link_to_polymorphic_trackable(record),
        parameters:     record.pretty_parameters
      }
    end
  end

  private

    def get_raw_records
      if (options[:trackable_id]).present? && (options[:trackable_type]).present?
        Work.where(trackable_id: options[:trackable_id], trackable_type: options[:trackable_type]).includes(:author).references(:author).all
      elsif (options[:only_for_current_user_id]).present?
        Work.where(user_id: options[:only_for_current_user_id]).includes(:author).references(:author).all
      else
        Work.includes(:author).references(:author).all
      end
    end

    def link_to_polymorphic_trackable(rec)
      if rec.trackable
        rec.url.html_safe
      else
        rec.trackable_id
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
