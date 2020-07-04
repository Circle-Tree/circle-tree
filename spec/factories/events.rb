# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "イベント#{n}" }
    start_date { Time.current.midnight.since(15.days) }
    end_date { Time.current.midnight.since(18.days) }
    answer_deadline { Time.current.midnight.since(10.days) }
    description { 'イベントの詳細です。' }
    comment { '楽しもう' }
    association :user
    association :group

    trait :invalid do
      name { nil }
    end
  end
end
