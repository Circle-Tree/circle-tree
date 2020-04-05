class Orders::Paypal

  # 支払いの完了したorderを探す
  def self.finish(charge_id)
    order = Order.paypal_executed.recently_created.find_by(charge_id: charge_id)
    return nil if order.nil?

    order.set_paid # statusをset_paidに変更
    order
  end

  # paymentを作成してtokenを生成する
  def self.create_payment(order:, product:)
    payment_price = (product.price_cents).to_s # 日本円は少数含まない
    currency = "JPY"
    payment = PayPal::SDK::REST::Payment.new({
      intent:  "sale",
      payer:  {
        payment_method: "paypal" },
      redirect_urls: {
        return_url: "/",
        cancel_url: "/" },
      transactions:  [{
        item_list: {
          items: [{
            name: product.name,
            sku: product.name,
            price: payment_price,
            currency: currency,
            quantity: 1 }
            ]
          },
        amount:  {
          total: payment_price,
          currency: currency
        },
        description:  "Payment for: #{product.name}"
      }]
    })
    if payment.create
      order.token = payment.token
      order.charge_id = payment.id
      return payment.token if order.save
    end
  end

  # paymentを実行する
  def self.execute_payment(payment_id:, payer_id:)
    order = Order.recently_created.find_by(charge_id: payment_id)
    return false unless order
    payment = PayPal::SDK::REST::Payment.find(payment_id) # 過去1分以内に作成されたorderの中から検索
    if payment.execute( payer_id: payer_id )
      order.set_paypal_executed # statusをpaypal_executedに変更
      return order.save
    end
  end

  def self.create_subscription(order:, product:)
    agreement = PayPal::SDK::REST::Agreement.new({
      name: product.name,
      description: "#{product.name}のサブスクリプション",
      start_date: (Time.current + 1.minute).iso8601,
      payer: {
        payment_method: "paypal"
      },
      plan: {
        id: product.paypal_plan_name
      }
    })
    if agreement.create
      order.token = agreement.token
      return agreement.token if order.save
    end
  end

  def self.execute_subscription(token:)
    order = Order.recently_created.find_by(token: token)
    return false unless order

    agreement = PayPal::SDK::REST::Agreement.new
    agreement.token = token
    if agreement.execute
      order.charge_id = agreement.id
      order.set_paypal_executed
      return order.charge_id if order.save
    end
  end
end
