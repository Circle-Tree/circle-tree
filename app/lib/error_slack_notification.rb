class ErrorSlackNotification
  def self.member_change_error_notify(title:, message:)
    notifier = Slack::Notifier.new(ENV['ERROR_SLACK_WEBHOOK_URL'])
    attachments = {
      title: title,
      text: message,
      color: 'danger'
    }
    notifier.post attachments: [attachments]
    Rails.logger.error message
  end
end
