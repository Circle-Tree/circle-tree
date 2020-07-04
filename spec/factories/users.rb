# frozen_string_literal: true

require 'gimei'

FactoryBot.define do
  factory :user do
    gimei = Gimei.new
    name { gimei.kanji }
    furigana { gimei.katakana.gsub(' ', '') }
    sequence(:email) { |n| "gimei_#{n}@example.com" }
    sequence(:grade) { |n| n % 6 }
    gender { gimei.female? }
    password { 'aoahbu30sn' }
    admin { false }
    definitive_registration { true }
    agreement { true }
    confirmed_at { Time.now }

    trait :invalid do
      name { nil }
    end

    trait :admin do
      admin { true }
    end

    trait :difinitive do
      definitive_registration { false }
    end
  end
end
