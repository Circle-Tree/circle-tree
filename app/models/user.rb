# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :group_users, dependent: :destroy
  has_many :group, through: :group_users
  # has_many :groups, through: :group_users
  accepts_nested_attributes_for :group_users
  has_many :answers, dependent: :destroy
  has_many :events, through: :answers # :nullifyの方がよいか？
  has_many :transactions, dependent: :destroy # :nullifyの方がよいか？
  # has_many :transactions, foreign_key: :debtor_id, dependent: :destroy
  # has_many :transactions, foreign_key: :creditor_id, dependent: :destroy
  has_many :fees # 不必要
  has_many :questionnaires
  validates :name, presence: true, length: { maximum: 100 }
  validates :definitive_registration, inclusion: { in: [true, false] }
  validates :admin, inclusion: { in: [true, false] }
  validates :furigana, presence: true, on: %i[create]
  # VALID_FURIGANA_REGEX = /\A[\p{katakana}　ー－&&[^ -~｡-ﾟ]]+\z/.freeze
  validates :furigana, format: { with: /\A[\p{katakana}　ー－&&[^ -~｡-ﾟ]]+\z/, message: 'は全角カタカナのみで入力して下さい。' }, allow_blank: true
  enum grade: {
    other: 0,
    grade1: 1,
    grade2: 2,
    grade3: 3,
    grade4: 4,
    grade5: 5,
    grade6: 6
  }
  validates :grade, presence: true
  validates :gender, inclusion: { in: [true, false], message: 'が入力されていません。' }
  # with_options unless: -> { validation_context == :batch || :update_password } do |batch|
  #   batch.validates :gender, inclusion: { in: [true, false] }
  #   batch.validates :grade, presence: true
  #   batch.validates :furigana, presence: true
  # end
  validates_acceptance_of :agreement, allow_nil: false, message: 'への同意が必要です。', on: :create

  def admin?
    admin
  end

  def executive?(group)
    if GroupUser.find_by(group_id: group.id, user_id: id, role: GroupUser.roles[:executive])
      true
    else
      false
    end
  end

  def attending?(event)
    answers.find_by(event_id: event.id, status: Answer.statuses[:attending]).present?
  end

  # オープンクラスにいずれ移動
  def is_gender_boolean?
    !!gender == gender
  end

  def to_readable_grade
    grade = User.grades[self.grade.to_sym]
    grade.zero? ? 'その他' : grade
  end

  def to_readable_gender
    gender ? '女性' : '男性'
  end

  # 論理削除用メソッド
  def leave
    update_attribute(:leave_at, Time.current)
  end

  # ユーザーのアカウントが有効であることを確認
  def active_for_authentication?
    super && !leave_at
  end

  # 削除したユーザーにカスタムメッセージを追加します
  def inactive_message
    !leave_at ? super : :deleted_account
  end

  def self.import!(file:, group:, password:)
    added_users = []
    transaction do
      CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: 'CP932:UTF-8') do |row|
        name = row['名前']
        email = row['メールアドレス']
        furigana = row['フリガナ']&.tr('ぁ-ん', 'ァ-ン')
        gender = return_gender_format(row['性別'])
        grade = return_grade_format(row['学年'])
        user = User.new(name: name, email: email, password: password,
                        definitive_registration: false, gender: gender, grade: grade, furigana: furigana)
        user.skip_confirmation!
        user.save!(context: :batch)
        GroupUser.create!(group_id: group.id, user_id: user.id, role: GroupUser.roles[:general])
        added_users << user
      end
    end
    added_count = added_users.count
    { added_users: added_users, added_count: added_count, status: 'success' }
  rescue ActiveRecord::RecordInvalid => e
    ErrorUtility.log_and_notify(e)
    puts e.class
    failed_number = added_users.count + 1
    error_message = e.message.gsub!(/バリデーションに失敗しました: /, '')
    puts error_message
    error_message = error_message.gsub!(/。/, '') + "(#{failed_number}人目)。" unless error_message.include?('パスワード')
    { error_message: error_message, status: 'failure' }
  rescue StandardError => e
    ErrorUtility.log_and_notify(e)
    { error_message: '何らかのエラーが発生しました。', status: 'failure' }
  end

  # あるグループの幹事たち
  def self.executives(group)
    executives = []
    GroupUser.where(group_id: group.id, role: GroupUser.roles[:executive]).each do |relationship|
      executives << User.find(relationship.user_id)
    end
    executives
  end

  # あるグループの一般ピーポー
  def self.generals(group)
    generals = []
    GroupUser.where(group_id: group.id, role: GroupUser.roles[:general]).each do |relationship|
      generals << User.find(relationship.user_id)
    end
    generals
  end

  # あるグループのメンバー
  def self.members(group)
    members = []
    GroupUser.where(group_id: group.id).each do |relationship|
      members << User.find(relationship.user_id)
    end
    members
  end

  def self.members_by_grade(group:, grade:)
    members = []
    GroupUser.where(group_id: group.id).each do |relationship|
      user = User.find_by(id: relationship.user_id, grade: grade)
      members << user if user
    end
    members # .sort_by { |member| member.furigana } # 配列をフリガナ順に並べる
  end

  # 支払いが済んでいない人たち
  def self.uncompleted_transactions_and_members(answers:, event:)
    users = []
    transactions = []
    answers.each do |answer|
      user = answer.user
      transaction = Event::Transaction.find_by(event_id: event.id, debtor_id: user.id)
      next unless transaction

      unless transaction.completed?
        transactions << transaction
        users << user
      end
    end
    { uncompleted_transactions: transactions, unpaid_members: users }
  end

  def self.return_gender_format(str)
    case str
    when '女'
      true
    when '男'
      false
    end
  end

  def self.return_grade_format(str)
    number = str.to_i
    if str == '0'
      number
    elsif number >= 1 && number <= 6
      number
    end
  end
end
