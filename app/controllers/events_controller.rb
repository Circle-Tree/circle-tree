# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!, only: %i[index list show new create edit update destroy]
  before_action :confirm_definitive_registration, only: %i[index list show new create edit update destroy]
  before_action :set_group, only: %i[index show details new create edit update destroy]
  before_action :cannot_access_to_other_groups, only: %i[index show new create edit update destroy]
  before_action :other_user_cannot_access, only: %i[list]
  before_action :only_executives_can_access, only: %i[index show new create edit update destroy]

  def index
    @events = Event.where(group_id: current_user_group.id).order(start_date: :asc).page(params[:page]).per(10)
  end

  def list
    @events = Event.my_groups_events(current_user).includes(:group).order(start_date: :asc).page(params[:page]).per(10)
  end

  def show
    @event = @group.events.find(params[:id])
    answer_hash = Answer.divide_answers_in_three(@event)
    @attending_answers = answer_hash[:attending].page(params[:page]).per(10) # 出席
    @absent_answers = answer_hash[:absent].page(params[:page]).per(10) # 欠席
    @unanswered_answers = answer_hash[:unanswered].includes(:user).page(params[:page]).per(10) # 未回答

    uncompleted_hash = User.uncompleted_transactions_and_members(answers: answer_hash[:attending].includes(:user), event: @event)
    @uncompleted_transactions = Kaminari.paginate_array(uncompleted_hash[:uncompleted_transactions]).page(params[:page]).per(10)
    @unpaid_members = uncompleted_hash[:unpaid_members]

    # @total_payment = @uncompleted_transactions.sum { |transaction| transaction[:payment] }
    # @expected_total_payment = @uncompleted_transactions.sum { |transaction| transaction[:debt] }

    @counts = {
      attending_count: answer_hash[:attending].count,
      absent_count: answer_hash[:absent].count,
      uncompleted_count: uncompleted_hash[:unpaid_members].count,
      unanswered_count: answer_hash[:unanswered].count
    }
  end

  def details
    @event = @group.events.find(params[:id])
    if user_signed_in?
      @answer = @event.answers.find_by(user_id: current_user.id)
      @attending_answers = @event.answers.where(status: 'attending').includes(:user)
      @is_my_group = @group.my_group?(current_user)
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      members = User.members(@group)
      members.delete(current_user) # イベント作成者は除く
      # Event::Transaction.new_transaction_when_create_new_event(member: current_user, group: @group, event: @event, creditor: current_user)
      Answer.new_answer_when_create_new_event(user: current_user, event: @event)
      # creditor = User.find(@event.user_id)
      NewEventJob.perform_later(members: members, current_user: current_user, group: @group, event: @event)
      flash[:success] = 'イベントが作成されました。グループのユーザーにメールで作成を通知しました。'
      redirect_to group_event_url(group_id: @group.id, id: @event.id)
    else
      render 'new'
    end
  end

  def edit
    @event = @group.events.find(params[:id])
  end

  def update
    @event = @group.events.find(params[:id])
    members = User.members(@group)
    if @event.update(event_params)
      UpdateEventJob.perform_later(members: members, current_user: current_user, group: @group, event: @event)
      flash_and_redirect(key: :success, message: 'イベント情報を更新しました。グループのユーザーにメールで変更を通知しました。', redirect_url: group_event_url(group_id: @group.id, id: @event.id))
    else
      render 'edit'
    end
  end

  def destroy
    event = @group.events.find(params[:id])
    if event.destroy
      flash_and_redirect(key: :success, message: 'イベントを削除しました', redirect_url: group_events_url(group_id: event.group_id, id: event.id))
    else
      flash_and_render(key: :danger, message: 'エラーにより削除できませんでした', action: 'show')
    end
  end

  private

    def event_params
      params.require(:event).permit(:name, :start_date, :end_date, :answer_deadline,
                                    :description, :comment, :user_id, :group_id)
    end

    def cannot_access_to_other_groups
      return if current_user.blank?

      super
    end
end
