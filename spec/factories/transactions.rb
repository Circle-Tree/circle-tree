FactoryBot.define do
  factory :transaction do
    deadline { Time.current.midnight.since(10.days) }
    debt { 5000 }
    payment { 5000 }
    association :debtor, factory: :user
    association :creditor, factory: :user
    sequence(:url_token) { |n| "#{n}#{SecureRandom.hex(10)}" }

    trait :invalid do
      type { nil }
    end
  end

  factory :event_transaction, class: Event::Transaction do
    deadline { Time.current.midnight.since(10.days) }
    debt { 5000 }
    payment { 5000 }
    association :debtor, factory: :user
    association :creditor, factory: :user
    association :event
    sequence(:url_token) { |n| "#{n}#{SecureRandom.hex(10)}" }

    trait :uncompleted do
      payment { 0 }
    end

    trait :overpaid do
      payment { 10000 }
    end
  end

  # factory :group_transaction, class: Group::Transaction do
  #   deadline { Time.current.midnight.since(10.days) }
  #   debt { 3000 }
  #   payment { 3000 }
  #   association :debtor, factory: :user
    # association :creditor, factory: :user
  #   association :group
  #   sequence(:url_token) { |n| "#{n}#{SecureRandom.hex(10)}" }

  #   trait :uncompleted do
  #     payment { 0 }
  #   end
    # trait :overpaid do
    #   payment { 10000 }
    # end
  # end

  factory :individual_transaction, class: Individual::Transaction do
    deadline { Time.current.midnight.since(10.days) }
    debt { 3000 }
    payment { 3000 }
    association :debtor, factory: :user
    association :creditor, factory: :user
    sequence(:url_token) { |n| "#{n}#{SecureRandom.hex(10)}" }
    memo { 'メモ' }

    trait :uncompleted do
      payment { 0 }
    end

    trait :overpaid do
      payment { 10000 }
    end
  end
end
