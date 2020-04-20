# frozen_string_literal: true

class Individual::Transaction < Transaction
  def lending?(user:)
    creditor_id == user.id
  end
end
