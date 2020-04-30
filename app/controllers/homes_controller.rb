# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :authenticate_user!, only: %i[index faq]
  before_action :confirm_definitive_registration
  def index
    user = current_user
    @my_groups = Group.my_groups(user)
    today = Time.current.midnight
    @events = Event.my_attending_events(user).where('start_date >= ?', today).order(start_date: :asc).limit(5)
    @new_events = Event.my_groups_events(user).where(created_at: (today - 7.days)..today.end_of_day).limit(4).order(created_at: :desc)
    transactions = Transaction.transactions_for_attending_event_by_user(user)
    @total_payment = transactions.sum { |transaction| transaction[:payment] }
    uncompleted_transactions = Transaction.uncompleted_transactions_by_user(transactions)
    overdue_transactions = Transaction.overdue_transactions_by_user(uncompleted_transactions: uncompleted_transactions, today: today)
    @total_overdue_debt = overdue_transactions.sum { |transaction| transaction[:debt] } - overdue_transactions.sum { |transaction| transaction[:payment] }
    non_overdue_transactions = uncompleted_transactions - overdue_transactions
    @total_non_overdue_debt = non_overdue_transactions.sum { |transaction| transaction[:debt] } - non_overdue_transactions.sum { |transaction| transaction[:payment] }
    @urgent_transactions = Transaction.urgent_transactions_by_user(non_overdue_transactions: non_overdue_transactions, max: 2, today: today)
  end

  def faq
  end

  def landing
  end

  def privacy_policy
  end

  def terms_of_service
  end
end
