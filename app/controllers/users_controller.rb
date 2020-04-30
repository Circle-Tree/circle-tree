# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: %i[index batch]
  before_action :cannot_access_to_other_groups, only: %i[index batch]
  before_action :only_executives_can_access, only: %i[batch]
  require 'csv'

  def index
    # いずれメタプログラミング
    @members1 = Kaminari.paginate_array(User.members_by_grade(group: @group, grade: User.grades[:grade1]))
    @members2 = Kaminari.paginate_array(User.members_by_grade(group: @group, grade: User.grades[:grade2]))
    @members3 = Kaminari.paginate_array(User.members_by_grade(group: @group, grade: User.grades[:grade3]))
    @members4 = Kaminari.paginate_array(User.members_by_grade(group: @group, grade: User.grades[:grade4]))
    @members5 = Kaminari.paginate_array(User.members_by_grade(group: @group, grade: User.grades[:grade5]))
    @members6 = Kaminari.paginate_array(User.members_by_grade(group: @group, grade: User.grades[:grade6]))
    @others = Kaminari.paginate_array(User.members_by_grade(group: @group, grade: User.grades[:other]))
  end

  def join
    @group_user = GroupUser.new
  end

  def leave
    @group_user = GroupUser.new
    @my_groups = Group.my_general_groups(current_user)
  end

  def withdraw

  end

  def share
    group = Group.find(params[:group_id])
    users = []
    GroupUser.where(group_id: group.id).each do |relationship|
      user = User.find(relationship.user_id)
      users << user unless user.definitive_registration
    end
    # users = User.where(group_id: group.id).where(definitive_registration: false)
    respond_to do |format|
      format.html
      format.csv do
        share_csv(users)
      end
    end
  end

  def csv_template
    respond_to do |format|
      format.html
      format.csv do
        send_template_csv
      end
    end
  end

  def batch
    file = params[:file]
    if file.blank?
      flash_and_redirect(key: :danger, message: 'ファイルを選択してください。', redirect_url: change_group_url(@group))
      return
    elsif File.extname(file.original_filename) != '.csv'
      flash_and_redirect(key: :danger, message: 'csvファイルのみ読み込み可能です。', redirect_url: change_group_url(@group))
      return
    elsif params[:password].blank?
      flash_and_redirect(key: :danger, message: 'パスワードを入力してください。', redirect_url: change_group_url(@group))
      return
    end

    hash = User.import!(file: file, group: @group, password: params[:password])
    if hash[:status] == 'success'
      added_users = hash[:added_users]
      added_count = hash[:added_count]
      if added_count <= 0
        flash_and_redirect(key: :danger, message: 'データがありません', redirect_url: change_group_url(@group))
      else
        added_users.each do |user|
          NotificationMailer.send_when_batch_registration(user: user, current_user: current_user, group: @group).deliver_later(wait: 1.minute)
        end
        flash_and_redirect(key: :success, message: "#{added_count}人のユーザーを追加し通知メールを送信しました。",
                           redirect_url: group_users_url(group_id: @group.id))
      end
    else
      flash_and_redirect(key: :danger, message: hash[:error_message], redirect_url: change_group_url(@group))
    end
  end

  private

    def send_template_csv
      # bom = "\uFEFF"
      csv = CSV.generate(force_quotes: true, encoding: Encoding::SJIS) do |c|
        header = %w[名前 メールアドレス フリガナ 性別 学年]
        c << header
      end
      send_data(csv, filename: 'template.csv', type: 'application/csv')
    end

    def share_csv(users)
      # bom = "\uFEFF"
      csv = CSV.generate(force_quotes: true, encoding: Encoding::SJIS) do |c|
        header = %w[名前 メールアドレス]
        c << header

        users.each do |user|
          values = [user.name, user.email]
          c << values
        end
      end
      send_data(csv, filename: 'share.csv', type: 'application/csv')
    end
end
