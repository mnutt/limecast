ExceptionNotifier.sender_address = %("LimeCast Application Error" <errors@limecast.com>)
exception_notified_email_config = "#{RAILS_ROOT}/private/exception_notified_emails.yml"
if File.exist? exception_notified_email_config
  ExceptionNotifier.exception_recipients = YAML::load_file(exception_notified_email_config)
else
  ExceptionNotifier.exception_recipients = []
end
