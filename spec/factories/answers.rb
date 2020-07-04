FactoryBot.define do
  factory :answer, aliases: [:attending] do
    status { Answer.statuses[:attending] }
    reason { Answer.reasons[:nothing] }
    association :user
    association :event

    trait :invalid do
      status { nil }
    end

    trait :unanswered do
      status { Answer.statuses[:unanswered] }
    end

    trait :absent do
      status { Answer.statuses[:absent] }
    end
  end
end
