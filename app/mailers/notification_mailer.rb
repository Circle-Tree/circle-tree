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

  def send_when_make_new_event(user, current_user, group, event)
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
end
