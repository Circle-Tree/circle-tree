# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_22_060158) do

  create_table "answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "status", default: 10, null: false, comment: "回答のステータス"
    t.bigint "user_id", null: false, comment: "回答者のUserID"
    t.bigint "event_id", null: false, comment: "イベントID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reason", default: 0, null: false
    t.index ["event_id"], name: "fk_rails_a4147b4302"
    t.index ["user_id", "event_id"], name: "index_answers_on_user_id_and_event_id", unique: true
  end

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.datetime "start_date", null: false, comment: "開始日"
    t.datetime "end_date", null: false, comment: "終了日"
    t.datetime "answer_deadline", null: false, comment: "回答期限"
    t.text "description", null: false, comment: "イベント説明"
    t.string "comment"
    t.index ["group_id"], name: "index_events_on_group_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "group_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group_number", null: false
    t.integer "payment_status", default: 0, null: false, comment: "支払い状況"
    t.index ["group_number"], name: "index_groups_on_group_number", unique: true
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id"
    t.integer "user_id"
    t.integer "status", default: 0
    t.string "token"
    t.string "charge_id"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
  end

  create_table "products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "paypal_plan_name"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "JPY", null: false
  end

  create_table "transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "deadline"
    t.integer "debt"
    t.integer "payment", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "debtor_id"
    t.bigint "creditor_id"
    t.bigint "event_id"
    t.bigint "group_id"
    t.string "type"
    t.string "url_token", null: false
    t.string "memo", comment: "支払い/貸し借りのメモ"
    t.index ["creditor_id"], name: "index_transactions_on_creditor_id"
    t.index ["debtor_id"], name: "index_transactions_on_debtor_id"
    t.index ["event_id"], name: "index_transactions_on_event_id"
    t.index ["group_id"], name: "index_transactions_on_group_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.boolean "definitive_registration", default: true, null: false
    t.boolean "gender", comment: "性別"
    t.integer "grade", comment: "学年"
    t.string "furigana", comment: "フリガナ"
    t.boolean "admin", default: false, null: false, comment: "管理者"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["furigana"], name: "index_users_on_furigana"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "events"
  add_foreign_key "answers", "users"
  add_foreign_key "events", "groups"
  add_foreign_key "events", "users"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "transactions", "events"
  add_foreign_key "transactions", "groups"
  add_foreign_key "transactions", "users", column: "creditor_id"
  add_foreign_key "transactions", "users", column: "debtor_id"
end
