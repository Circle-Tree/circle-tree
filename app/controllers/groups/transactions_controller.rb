# frozen_string_literal: true
# 今後実装予定
# class Groups::TransactionsContrller < TransactionsController
#   before_action :authenticate_user!
#   def new
#     @group = Group.find(params[:group_id])
#     @transaction = Group::Transaction.new
#     @users = []
#     GroupUser.where(group_id: @group.id).each do |relationship|
#       user = User.find(relationship.user_id)
#       unless Group::Transaction.where(group_id: @group.id, event_id: null, debtor_id: relationship.user_id)
#         @users << user
#       end
#     end
#   end
#
#   def index
#     @group = Group.find(params[:group_id])
#     @transactions = Group::Transaction.where(group_id: @group.id)
#   end
# end
