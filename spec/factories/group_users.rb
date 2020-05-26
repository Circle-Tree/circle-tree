FactoryBot.define do
  factory :group_user, aliases: [:general] do
    role { GroupUser.roles[:general] }
    association :user
    association :group

    trait :invalid do
      role { nil }
    end

    trait :executive do
      role { GroupUser.roles[:executive] }
    end
  end
end
