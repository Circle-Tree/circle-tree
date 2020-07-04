# frozen_string_literal: true

class ErrorSlackNotification
  def self.general_error_notify(title:, message:)
    notifier = Slack::Notifier.new(ENV['ERROR_SLACK_WEBHOOK_URL'])
    attachments = {
      title: title,
      text: message,
      color: 'danger'
    }
    notifier.post attachments: [attachments]
    Rails.logger.error message
  end

  def self.new_subscription_error_notify(title:, message:)
    notifier = Slack::Notifier.new(ENV['SUBSCRIPTION_SLACK_WEBHOOK_URL'])
    attachments = {
      title: title,
      text: message,
      color: 'danger'
    }
    notifier.post attachments: [attachments]
    Rails.logger.error message
  end
end
