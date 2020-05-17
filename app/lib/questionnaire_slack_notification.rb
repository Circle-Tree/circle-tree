class QuestionnaireSlackNotification
  def self.created_questionnaire_notify(title:, message:)
    notifier = Slack::Notifier.new(ENV['QUESTIONNAIRE_SLACK_WEBHOOK_URL'])
    attachments = {
      title: title,
      text: message,
      color: 'success'
    }
    notifier.post attachments: [attachments]
  end
end
