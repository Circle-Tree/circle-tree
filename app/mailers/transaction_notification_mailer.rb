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

  def update_lending_transaction(user:, current_user:)
    @user = user
    @current_user = current_user
    mail(
      subject: '新規支払い情報の作成',
      to: @user.email
    ) do |format|
      format.text
    end
  end

  def update_borrowing_transaction(user:, current_user:)
    @user = user
    @current_user = current_user
    mail(
      subject: '新規支払い情報の作成',
      to: @user.email
    ) do |format|
      format.text
    end
  end
end
