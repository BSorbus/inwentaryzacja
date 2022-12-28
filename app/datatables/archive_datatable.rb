require 'my_human'

class ArchiveDatatable < AjaxDatatablesRails::ActiveRecord
  include  ActionView::Helpers::NumberHelper

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
      note:           { source: "Archive.note", cond: :like, searchable: true, orderable: true },
      expiry_on:      { source: "Archive.expiry_on", cond: :like, searchable: true, orderable: true },
      folders_count:  { source: "Archive.folders_count", cond: :like, searchable: false, orderable: false },
      files_count:    { source: "Archive.files_count", cond: :like, searchable: false, orderable: false },
      files_size_sum: { source: "Archive.files_size_sum", cond: :like, searchable: false, orderable: false }
      # author:         { source: "User.user_name",  cond: :like, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |record|
      {
        id:             record.id,
        name:           link_to( record.fullname, archive_path(record) ),
        note:           record.note_truncate,
        expiry_on:      record.expiry_on.present? ? record.expiry_on.strftime("%Y-%m-%d") : '' ,
        folders_count:  folders_count_badge(record).html_safe,
        files_count:    files_count_badge(record).html_safe,
        files_size_sum: human_files_size_sum(record).html_safe
        # author:         link_to( record.author.fullname, user_path(record.author_id) )
      }
    end
  end

  private

    def get_raw_records
      data = Archive.joins(:author, accesses_groups: {users: []})
              .includes(archivizations: [:archivization_type]).references(:author, accesses_groups: [:user])

      options[:eager_filter].present? ? data.for_user_in_archivizations(options[:eager_filter]).all : data.all

    end

    def folders_count_badge(rec)
      count = rec.components.where(component_file: nil).size
      "<span class='badge alert-info pull-right'> #{count} </span></div>"
    end

    def files_count_badge(rec)
      count = rec.components.where.not(component_file: nil).size
      "<span class='badge alert-info pull-right'> #{count} </span></div>"
    end

    def files_size_sum(rec)
      rec.components.where.not(component_file: nil).map {|a| a.component_file.file.size }.sum
    end

    def human_files_size_sum(rec)
      rec_files_size_sum = files_size_sum(rec)
      rec_files_quota = rec.quota

      procentage_used = ((rec_files_size_sum.to_f / rec_files_quota.to_f) * 100).round(0)

      # human_size = number_to_human_size(rec_files_size_sum)
      # human_quota = number_to_human_size(rec_files_quota)
      human_size = MyHuman.new.filesize(rec_files_size_sum)
      human_quota = MyHuman.new.filesize(rec_files_quota)
 
      case procentage_used
      when 0..50
        bar_type = 'success'
      when 51..75
        bar_type = 'warning'
      when 76..100
        bar_type = 'danger'        
      end

      "<div class='progress' style='margin-bottom: 0px;'>
        <div class='progress-bar progress-bar-#{bar_type}' role='progressbar' aria-valuenow='#{rec_files_size_sum}' aria-valuemin='0' aria-valuemax='#{rec_files_quota}' style='width: #{procentage_used}%;'>
          #{procentage_used}%
        </div>
      </div>
      <div>
        <span class='pull-right'>#{human_size}/#{human_quota}</span>
      </div>"

    end

end
