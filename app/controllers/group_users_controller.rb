class GroupUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :only_executives_can_access

  def invite
    @group = current_user_group
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
        flash_and_redirect(key: :success, message: "#{group.name}に参加しました。", redirect_url: root_url)
      else
        flash_and_render(key: :danger, message: "すでに#{group.name}に参加しています。", action: 'users/join')
      end
    else
      flash_and_render(key: :danger, message: 'サークルIDに間違いがあります。', action: 'users/join')
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
end
