# frozen_string_literal: true

FactoryBot.define do
  factory :fee do
    amount { 1000 }
    grade { Fee.grades[:grade1] }
    deadline { Time.current.midnight.since(10.days) }
    association :event
    association :creditor, factory: :user

    trait :invalid do
      name { nil }
    end
  end
end
