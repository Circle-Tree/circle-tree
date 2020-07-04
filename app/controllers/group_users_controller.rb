# frozen_string_literal: true

class GroupUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group, only: %i[invite]
  before_action :only_executives_can_access, only: %i[invite]

  def invite
    @executives = User.executives(@group)
    email = params[:email].try(:downcase)
    return flash_and_render(key: :danger, message: 'メールアドレスを入力してください。', action: 'groups/change') if email.blank?

    user = User.find_by(email: email)
    if user.present?
      relationship = GroupUser.new(group_id: @group.id, user_id: user.id, role: GroupUser.roles[:general])
      if relationship.save
        NotificationMailer.invite(group: @group, user: user, current_user: current_user).deliver_later
        flash_and_redirect(key: :success, message: "#{user.name}さんを招待しました。", redirect_url: change_group_url(@group))
      else
        flash_and_render(key: :danger, message: 'そのメールアドレスのユーザーはすでにグループに所属しています。', action: 'groups/change')
      end
    else
      flash_and_render(key: :danger, message: 'メールアドレスは登録されていないまたは間違いがあります。', action: 'groups/change')
    end
  end

  def join
    group = Group.find_by(group_number: params[:group_number])
    if group.present?
      relationship = GroupUser.new(user_id: params[:user_id].to_i, group_id: group.id, role: GroupUser.roles[:general])
      if relationship.save
        flash_and_redirect(key: :success, message: "#{group.name}に参加しました。", redirect_url: home_url)
      else
        flash_and_render(key: :danger, message: "すでに#{group.name}に参加しています。", action: 'users/join')
      end
    else
      flash_and_render(key: :danger, message: 'サークルIDに間違いがあります。', action: 'users/join')
    end
  end

  def leave
    relationship = GroupUser.find_by(group_user_params)
    if relationship.present?
      group = relationship.group
      if group.my_own_group?(current_user)
        @group_user = GroupUser.new
        @my_groups = Group.my_general_groups(current_user)
        flash_and_render(
          key: :danger,
          message: '幹事であるグループからは退会できません。幹事を辞退してからもう一度行ってください。',
          action: 'users/leave'
        )
      elsif relationship.destroy
        flash_and_redirect(key: :success, message: "#{group.name}から退会しました。", redirect_url: home_url)
      else
        @group_user = GroupUser.new
        @my_groups = Group.my_general_groups(current_user)
        flash_and_render(key: :danger, message: "#{group.name}から退会できませんでした。", action: 'users/leave')
      end
    else
      @group_user = GroupUser.new
      @my_groups = Group.my_general_groups(current_user)
      flash_and_render(key: :danger, message: 'グループを選択してください。', action: 'users/leave')
    end
  end

  def destroy
    relationship = GroupUser.find(params[:id])
    if relationship.destroy
      user = User.find(relationship.user_id)
      flash_and_redirect(key: :success, message: "#{user.name}さんを退会させました", redirect_url: group_users_url(group_id: relationship.group_id))
    else
      flash_and_render(key: :danger, message: 'エラーにより削除できませんでした', action: 'users/index')
    end
  end

  def group_user_params
    params.require(:group_user).permit(:group_id, :user_id)
  end
end
