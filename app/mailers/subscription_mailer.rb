class SubscriptionMailer < ApplicationMailer
  def new_subscription(group:, user:, order:)
    @group = group
    @user = user
    @product = Product.find(order.product_id)
    mail(
      subject: "#{@product.name}の購読のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end
end
