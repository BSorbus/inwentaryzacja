class CloudMailer < ApplicationMailer
  include AbstractController::Callbacks
  include ArchivesHelper
  include ComponentsHelper

  attr_accessor :attr_archive, :attr_component, :attr_sending_user

  default template_path: 'cloud_mailer' # to make sure that your mailer uses the devise views
  default from: Rails.application.secrets.email_provider_username
  default bcc: Rails.application.secrets.email_bcc_username

  after_action :attach_metadata

  def link_archive_show(archive, recipient, sending_user)
    @attr_archive = archive
    @attr_component = nil
    @attr_sending_user = sending_user

    @archive = archive
    @recipient = recipient
    @archive_fullname = "#{@archive.fullname}" # "#{archive_info_legend(@archive)}"
    @archive_note = "#{Loofah.fragment(@archive.note).text}"
    @archive_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'archives', action: 'show', id: @archive.id, locale: locale)

    attachments.inline['logo_mailer'] = File.read("app/assets/images/logo_mailer.png")
    attachments.inline['logo_uke'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @recipient.email, cc: sending_user.email, subject: "#{t('title')} - #{@archive_fullname}" )
  end

  def link_component_download(component, recipient, sending_user)
    @attr_archive = component.componentable
    @attr_component = component
    @attr_sending_user = sending_user

    @component = component
    @recipient = recipient
    @component_fullname = "#{@component.fullname}"
    @component_note = "#{Loofah.fragment(@component.note).text}"
    @component_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'components', action: 'download', id: @component.id, locale: locale)

    attachments.inline['logo_mailer'] = File.read("app/assets/images/logo_mailer.png")
    attachments.inline['logo_uke'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @recipient.email, cc: sending_user.email, subject: "#{t('title')} - #{@component_fullname}" )
  end

  def link_component_download_simple(component, recipient, sending_user)
    @attr_archive = component.componentable
    @attr_component = component
    @attr_sending_user = sending_user

    @component = component
    @recipient = recipient
    @component_fullname = "#{@component.fullname}"
    @component_note = "#{Loofah.fragment(@component.note).text}"
    @component_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'components', action: 'download_simple', id: @component.for_simple_download, locale: locale)

    attachments.inline['logo_mailer'] = File.read("app/assets/images/logo_mailer.png")
    attachments.inline['logo_uke'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @recipient.email, cc: sending_user.email, subject: "#{t('title')} - #{@component_fullname}" )
  end

  private

    def attach_metadata
      mailer_klass = self.class.to_s
      mailer_action = self.action_name
      mailer_archive = @attr_archive
      mailer_component = @attr_component
      mailer_sending_user = @attr_sending_user

      self.message.instance_variable_set(:@mailer_klass, mailer_klass)
      self.message.instance_variable_set(:@mailer_action, mailer_action)
      self.message.instance_variable_set(:@mailer_archive, mailer_archive)
      self.message.instance_variable_set(:@mailer_component, mailer_component)
      self.message.instance_variable_set(:@mailer_sending_user, mailer_sending_user)

      self.message.class.send(:attr_reader, :mailer_klass)
      self.message.class.send(:attr_reader, :mailer_action)
      self.message.class.send(:attr_reader, :mailer_archive)
      self.message.class.send(:attr_reader, :mailer_component)
      self.message.class.send(:attr_reader, :mailer_sending_user)
    end
end


# preview
# http://localhost:3000/rails/mailers/status_mailer/project_status_email.html