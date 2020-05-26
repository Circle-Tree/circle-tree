FactoryBot.define do
  factory :answer, aliases: [:attending] do
    status { Answer.statuses[:attending] }
    reason { Answer.reasons[:nothing] }
    association :user
    association :event

    trait :invalid do
      name { nil }
    end

    trait :unanswered do
      status { Answer.statuses[:unanswered] }
    end

    trait :attending do
      status { Answer.statuses[:absent] }
    end
  end
end
