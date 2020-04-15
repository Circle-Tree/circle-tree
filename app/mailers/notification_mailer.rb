# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def send_when_batch_registration(user, current_user)
    @user = user
    @current_user = current_user
    mail(
      subject: '仮登録のお知らせ',
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def send_when_make_new_event(user:, current_user:, group:, event:)
    @user = user
    @current_user = current_user
    @group = group
    @event = event
    mail(
      subject: '新規イベントのお知らせ',
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def send_when_update_event(user:, current_user:, group:, event:)
    @user = user
    @current_user = current_user
    @group = group
    @event = event
    mail(
      subject: "#{@event.name}のイベント情報更新のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def remind_answer(user, group, event)
    @user = user
    @group = group
    @event = event
    mail(
      subject: "#{@event.name}の回答をしてください",
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def remind_payment(debtor, group, event, transaction)
    @debtor = debtor
    @group = group
    @event = event
    @transaction = transaction
    mail(
      subject: "#{@event.name}の支払い期限が近づいています。",
      to: @debtor.email
    ) do |format|
      format.text
    end
  end

  def invite(group:, user:, current_user:)
    @group = group
    @user = user
    @current_user = current_user
    mail(
      subject: "#{@group.name}からの招待のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def inherit(group:, user:, current_user:)
    @group = group
    @user = user
    @current_user = current_user
    mail(
      subject: "#{@group.name}の幹事引継ぎのお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def assign(group:, user:, current_user:)
    @group = group
    @user = user
    @current_user = current_user
    mail(
      subject: "#{@group.name}の幹事任命のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def update_event_transaction(group:, transaction:, current_user:)
    @transaction = transaction
    event = @transaction.event
    @user = @transaction.debtor
    if @transaction.completed?
      @message = "#{current_user.name}さんによって#{event.name}(#{group.name})の支払いが完了状態となりました。"
      subject = "#{event.name}(#{group.name})の支払い完了のお知らせ"
    else
      @message = "#{current_user.name}さんが#{event.name}(#{group.name})の支払い情報を変更しました。"
      subject = "#{event.name}(#{group.name})の支払い情報変更のお知らせ"
    end
    mail(
      subject: subject,
      to: @user.email
    ) do |format|
      format.text
    end
  end
end
