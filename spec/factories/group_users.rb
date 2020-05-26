FactoryBot.define do
  factory :group_user do
    role { GroupUser.roles[:general] }
    association :user
    association :group

    trait :invalid do
      role { nil }
    end
  end
end
