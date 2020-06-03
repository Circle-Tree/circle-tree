class SuccessSlackNotification
  def self.new_subscription_notify(order:, current_user:)
    product = Product.find(order&.product_id)
    notifier = Slack::Notifier.new(ENV['SUBSCRIPTION_SLACK_WEBHOOK_URL'])
    attachments = {
      title: '新規サブスクリプション',
      text: "#{current_user&.name}(ID: #{current_user&.id})さんによって#{product.name}が購読されました！",
      color: 'good'
    }
    notifier.post attachments: [attachments]
  rescue => e
    ErrorUtility.log_and_notify(e)
  end

  def self.registration_notify
    count = User.count
    notifier = Slack::Notifier.new(ENV['SUBSCRIPTION_SLACK_WEBHOOK_URL'])
    attachments = {
      title: '新規ユーザー',
      text: "#{count}人目のユーザーが登録されました。",
      color: 'good'
    }
    notifier.post attachments: [attachments]
  rescue => e
    ErrorUtility.log_and_notify(e)
  end

  def self.new_group_notify
    count = Group.count
    notifier = Slack::Notifier.new(ENV['SUBSCRIPTION_SLACK_WEBHOOK_URL'])
    attachments = {
      title: '新規サークル',
      text: "#{count}個目のサークルが作成されました。",
      color: 'good'
    }
    notifier.post attachments: [attachments]
  rescue => e
    ErrorUtility.log_and_notify(e)
  end
end
