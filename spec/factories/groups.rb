FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "サークル#{n}" }
    sequence(:email) { |n| "circle_#{n}@example.com" }
    sequence(:group_number) { |n| "circle_number#{n}" }
    payment_status { Group.payment_statuses[:paid] }

    trait :invalid do
      name { nil }
    end

    trait :unpaid do
      payment_status { Group.payment_statuses[:unpaid] }
    end

    trait :inactive do
      payment_status { Group.payment_statuses[:inactive] }
    end
  end
end
