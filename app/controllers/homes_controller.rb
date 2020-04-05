# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  def index
    user = current_user
    @my_groups = Group.my_groups(user)
    today = Time.current.midnight
    @events = Event.my_attending_events(user).where('start_date >= ?', today).order(start_date: :asc).limit(5)
    @new_events = Event.my_events(user).where(created_at: (today - 7.days)..today.end_of_day).limit(4).order(created_at: :desc)
    @total_payment = Transaction.total_payment_by_user(user)
    all_debts = Transaction.joins(event: :answers).where(completed: false, debtor_id: user.id, event: { answers: { status: 'attending' } }).distinct
    t = Time.current.end_of_day
    unpaid_debts = all_debts.where('deadline <= ?', t)
    @total_unpaid_debt = unpaid_debts.sum('debt') - unpaid_debts.sum('payment')
    expected_debts = all_debts.where('deadline >= ?', t)
    @total_expected_debt = expected_debts.sum('debt') - expected_debts.sum('payment')
    @urgent_expected_debts = all_debts.where(deadline: t..t.since(7.days)).order(deadline: :asc).limit(2)
  end
end
