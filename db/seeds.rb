# frozen_string_literal: true

require 'gimei'
# Admin User
User.create!(
  name: '管理者',
  furigana: 'カンリシャ',
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: true,
  confirmed_at: Time.now,
  gender: false,
  grade: 3,
  admin: true,
  agreement: true
)

gimei1 = Gimei.name
# 幹事User1
User.create!(
  name: gimei1.kanji,
  furigana: gimei1.katakana.gsub(' ', ''),
  email: 'executive1@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: true,
  confirmed_at: Time.now,
  gender: gimei1.female?,
  grade: 3,
  agreement: true
)

gimei2 = Gimei.name
# 幹事User2
User.create!(
  name: gimei2.kanji,
  furigana: gimei2.katakana.gsub(' ', ''),
  email: 'executive2@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: true,
  confirmed_at: Time.now,
  gender: gimei2.female?,
  grade: 3,
  agreement: true
)

10.times do |i|
  gimei = Gimei.name
  User.create!(
    name: gimei.kanji,
    furigana: gimei.katakana.gsub(' ', ''),
    email: "General#{i + 1}@example.com",
    password: 'password',
    password_confirmation: 'password',
    definitive_registration: true,
    confirmed_at: Time.now,
    gender: gimei.female?,
    grade: i % 3,
    agreement: true
  )
end
gimei3 = Gimei.name
User.create!(
  name: gimei3.kanji,
  furigana: gimei3.katakana.gsub(' ', ''),
  email: 'definitive_test@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: false,
  confirmed_at: Time.now,
  gender: gimei3.female?,
  grade: 1,
  agreement: true
)

# Group

Group.create!(
  name: 'Group 1',
  email: 'executive1@example.com',
  group_number: 'group_test_1',
  payment_status: Group.payment_statuses[:paid]
)
Group.create!(
  name: 'Group 2',
  email: 'executive2@example.com',
  group_number: 'group_test_2',
  payment_status: Group.payment_statuses[:paid]
)

# GroupUser
# Executive 1(Group1) & 2(Group2)
2.times do |i|
  GroupUser.create!(
    group_id: i + 1,
    user_id: i + 2,
    role: 90
  )
end

# General 1 ~ 5
5.times do |i|
  GroupUser.create!(
    group_id: 1,
    user_id: i + 4,
    role: 10
  )
end
# General 6 ~ 10
5.times do |i|
  GroupUser.create!(
    group_id: 2,
    user_id: i + 9,
    role: 10
  )
end

# Executive 1 & Group 1のEvent
15.times do |i|
  Event.create!(
    name: "合宿#{i + 1}",
    user_id: 2,
    group_id: 1,
    start_date: Date.today.next_year(3).to_datetime,
    end_date: Date.today.next_year(3).to_datetime,
    answer_deadline: Date.today.next_year(3).to_datetime,
    description: "これは合宿#{i + 1}用のテスト説明です。",
    comment: '楽しいぞ！！！！！'
  )
end

# Executive 2 & Group 2のEvent
15.times do |i|
  Event.create!(
    name: "旅行#{i + 1}",
    user_id: 3,
    group_id: 2,
    start_date: Date.today.next_year(3).to_datetime,
    end_date: Date.today.next_year(3).to_datetime,
    answer_deadline: Date.today.next_year(3).to_datetime,
    description: "これは旅行#{i + 1}用のテスト説明です。",
    comment: '楽しいぞ！！！！！'
  )
end

15.times do |n|
  # Executive 1
  Event::Transaction.create!(
    deadline: Date.today.next_year(3).to_datetime,
    debt: (n + 1) * 1000,
    payment: (n + 1) * 1000,
    creditor_id: 2,
    debtor_id: 2,
    group_id: 1,
    event_id: n + 1,
    url_token: SecureRandom.hex(10)
  )
  Answer.create!(
    status: Answer.statuses[:attending],
    user_id: 2,
    event_id: n + 1
  )
  # General 1 ~ 5
  5.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n + 1) * 1000,
      payment: (n + 1) * 500,
      creditor_id: 2,
      debtor_id: i + 4,
      group_id: 1,
      event_id: n + 1,
      url_token: SecureRandom.hex(10)
    )
    Answer.create!(
      status: Answer.statuses[:attending],
      user_id: i + 4,
      event_id: n + 1
    )
  end
end

# Group 2 & Events 1~5のTransaction
15.times do |n|
  # Executive 2
  Event::Transaction.create!(
    deadline: Date.today.next_year(3).to_datetime,
    debt: (n + 1) * 1000,
    payment: (n + 1) * 1000,
    creditor_id: 3,
    debtor_id: 3,
    group_id: 2,
    event_id: n + 16,
    url_token: SecureRandom.hex(10)
  )
  Answer.create!(
    status: Answer.statuses[:attending],
    user_id: 3,
    event_id: n + 16
  )
  # User 9 ~ 13
  5.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n + 1) * 1000,
      payment: 0,
      creditor_id: 3,
      debtor_id: i + 9,
      group_id: 2,
      event_id: n + 16,
      url_token: SecureRandom.hex(10)
    )
    Answer.create!(
      status: Answer.statuses[:unanswered],
      user_id: i + 9,
      event_id: n + 16
    )
  end
end

Product.create!(
  name: '3か月プラン',
  paypal_plan_name: 'P-92S132272T043605MKSGL7WI',
  price_cents: 100
)
Product.create!(
  name: '6か月プラン',
  paypal_plan_name: 'P-92V71819AH9823618KSHTB2I',
  price_cents: 200
)
Product.create!(
  name: '12か月プラン',
  paypal_plan_name: 'P-9UY75926TX6644447EAODKPI',
  price_cents: 400
)
