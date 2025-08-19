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

ActiveRecord::Schema[7.2].define(version: 2025_08_19_124615) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "account_login_change_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "login", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_password_reset_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_remember_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_verification_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "status", default: 1, null: false
    t.citext "email", null: false
    t.string "password_hash"
    t.string "name"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "license_type_id"
    t.integer "current_month_tokens_used", default: 0, null: false
    t.date "user_month_start", default: -> { "CURRENT_DATE" }, null: false
    t.datetime "license_expires_at"
    t.boolean "license_auto_renew", default: true, null: false
    t.index ["current_month_tokens_used"], name: "index_accounts_on_current_month_tokens_used"
    t.index ["email"], name: "index_accounts_on_email", unique: true, where: "(status = ANY (ARRAY[1, 2]))"
    t.index ["license_expires_at"], name: "index_accounts_on_license_expires_at"
    t.index ["license_type_id"], name: "index_accounts_on_license_type_id"
  end

  create_table "ai_settings", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "default_provider"
    t.string "default_model"
    t.text "providers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ai_settings_on_account_id"
  end

  create_table "app_configs", force: :cascade do |t|
    t.integer "max_iterations", default: 10, null: false
    t.integer "max_original_text_length", default: 10000, null: false
    t.integer "max_result_text_length", default: 50000, null: false
    t.integer "max_instruction_length", default: 2000, null: false
    t.bigint "global_monthly_token_limit", default: 10000000, null: false
    t.bigint "global_current_month_tokens_used", default: 0, null: false
    t.decimal "token_price_usd", precision: 10, scale: 6, default: "0.000002", null: false
    t.date "global_month_start", null: false
    t.integer "estimated_tokens_per_call", default: 500, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "original_text", null: false
    t.jsonb "iterations", default: [], null: false
    t.integer "status", default: 0, null: false
    t.string "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_conversations_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_conversations_on_account_id"
    t.index ["iterations"], name: "index_conversations_on_iterations", using: :gin
    t.index ["session_id"], name: "index_conversations_on_session_id"
    t.index ["status"], name: "index_conversations_on_status"
  end

  create_table "license_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name", null: false
    t.text "description"
    t.integer "monthly_token_limit", null: false
    t.decimal "price_per_month", precision: 8, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.integer "max_conversations_per_day"
    t.integer "max_iterations_per_conversation"
    t.jsonb "features", default: {}
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_license_types_on_active"
    t.index ["name"], name: "index_license_types_on_name", unique: true
    t.index ["sort_order"], name: "index_license_types_on_sort_order"
  end

  create_table "llm_models", force: :cascade do |t|
    t.string "name", null: false
    t.string "provider", null: false
    t.string "model_id", null: false
    t.text "prompt", null: false
    t.jsonb "config", default: {}
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_llm_models_on_enabled"
    t.index ["provider", "model_id"], name: "index_llm_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_llm_models_on_provider"
  end

  create_table "user_prompts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "title", limit: 255, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_user_prompts_on_account_and_created_at"
    t.index ["account_id"], name: "index_user_prompts_on_account_id"
  end

  add_foreign_key "account_login_change_keys", "accounts", column: "id"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id"
  add_foreign_key "account_remember_keys", "accounts", column: "id"
  add_foreign_key "account_verification_keys", "accounts", column: "id"
  add_foreign_key "accounts", "license_types"
  add_foreign_key "ai_settings", "accounts"
  add_foreign_key "conversations", "accounts"
  add_foreign_key "user_prompts", "accounts"
end
