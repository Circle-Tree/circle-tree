class SuccessSlackNotification
  def self.new_subscription_notify(order)
    product = Product.find(order&.product_id)
    notifier = Slack::Notifier.new(ENV['SUBSCRIPTION_SLACK_WEBHOOK_URL'])
    attachments = {
      title: '新規サブスクリプション',
      text: "#{product.name}が購読されました！",
      color: 'good'
    }
    notifier.post attachments: [attachments]
  rescue => e
    ErrorUtility.log_and_notify(e)
  end
end
