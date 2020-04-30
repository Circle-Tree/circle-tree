# frozen_string_literal: true

class TransactionNotificationMailer < ApplicationMailer
  def new_event_transaction(user:, current_user:, event:)
    @user = user
    @current_user = current_user
    @event = event
    @group = event.group
    mail(
      subject: "#{@event.name}の支払い情報作成のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def edit_event_transaction(user:, current_user:, event:)
    @user = user
    @current_user = current_user
    @event = event
    @group = event.group
    mail(
      subject: "#{@event.name}の支払い情報変更のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

  # イベント収支の個人の情報変更
  def update_event_transaction(group:, transaction:, current_user:)
    @transaction = transaction
    event = @transaction.event
    @user = @transaction.debtor
    if @transaction.completed?
      @message = "#{current_user.name}さんによって#{group.name}の#{event.name}のあなたの支払いが完了状態に変更されました。"
      subject = "#{event.name}(#{group.name})の支払い完了のお知らせ"
    else
      @message = "#{current_user.name}さんが#{group.name}の#{event.name}のあなたの支払い情報を変更しました。"
      subject = "#{event.name}(#{group.name})の支払い情報変更のお知らせ"
    end
    mail(
      subject: subject,
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def new_lending_transaction(user:, current_user:)
    @user = user
    @current_user = current_user
    mail(
      subject: '貸し借りメモの作成のお知らせ',
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def new_borrowing_transaction(user:, current_user:)
    @user = user
    @current_user = current_user
    mail(
      subject: '貸し借りメモの作成のお知らせ',
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def update_lending_transaction(user:, current_user:)
    @user = user
    @current_user = current_user
    mail(
      subject: '貸し借りメモの変更のお知らせ',
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def update_borrowing_transaction(user:, current_user:)
    @user = user
    @current_user = current_user
    mail(
      subject: '貸し借りメモの変更のお知らせ',
      to: @user.email
    ) do |format|
      format.text
    end
  end
end
