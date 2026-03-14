# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_14_001450) do
  create_table "accounts", force: :cascade do |t|
    t.string "account_type", null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.string "institution_name"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["name"], name: "index_accounts_on_name"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "assets", force: :cascade do |t|
    t.string "asset_type"
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "description"
    t.string "name"
    t.date "purchase_date"
    t.decimal "purchase_price"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "name", null: false
    t.integer "parent_id"
    t.boolean "predefined", default: false, null: false
    t.string "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "recurring_templates", force: :cascade do |t|
    t.integer "account_id", null: false
    t.decimal "amount"
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "description"
    t.string "frequency"
    t.date "next_due_date"
    t.string "transaction_type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recurring_templates_on_account_id"
    t.index ["category_id"], name: "index_recurring_templates_on_category_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.integer "asset_id"
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.date "date", null: false
    t.string "description", null: false
    t.decimal "exchange_rate", precision: 10, scale: 6
    t.text "notes"
    t.integer "recurring_template_id"
    t.string "status", default: "paid", null: false
    t.string "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["asset_id"], name: "index_transactions_on_asset_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["recurring_template_id"], name: "index_transactions_on_recurring_template_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "assets", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categories", "users"
  add_foreign_key "recurring_templates", "accounts"
  add_foreign_key "recurring_templates", "categories"
  add_foreign_key "sessions", "users"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "assets"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "recurring_templates"
end
