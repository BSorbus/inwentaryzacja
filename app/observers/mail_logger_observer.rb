class MailLoggerObserver
  def self.delivered_email(mail)
    if mail.mailer_klass == "CloudMailer" && mail.mailer_action == "link_archive_show"
     #  puts '-------------------- MailLoggerObserver ------------------'
     #  puts "sender: #{mail.from}"
     #  puts "recipient: #{mail.to}"
     #  puts "bcc: #{mail.bcc}"
     #  puts "cc: #{mail.cc}"
     #  puts "subject: #{mail.subject}"
     #  puts "sent_at: #{mail.date}"
     #  #puts "body: #{body}"
     #  puts "mailer_klass: #{mail.mailer_klass}"
     #  puts "mailer_action: #{mail.mailer_action}"
     #  puts "mailer_archive: #{mail.mailer_archive}"
     #  puts "mailer_component: #{mail.mailer_component}"
     #  puts "mailer_sending_user: #{mail.mailer_sending_user}"
      mail.mailer_archive.log_work_send_email('send_link_archive_show', mail.mailer_sending_user.id, mail.to)
     #  puts '----------------------------------------------------------'
    end

    if mail.mailer_klass == "CloudMailer" && mail.mailer_action == "link_component_download"
      mail.mailer_component.log_work_send_email('send_link_component_download', mail.mailer_sending_user.id, mail.to)
    end

    if mail.mailer_klass == "CloudMailer" && mail.mailer_action == "link_component_download_simple"
      mail.mailer_component.log_work_send_email('send_link_component_download_simple', mail.mailer_sending_user.id, mail.to)
    end

  end
end