class GroupUsersController < ApplicationController
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
