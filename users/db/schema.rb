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

ActiveRecord::Schema.define(version: 20180829060106) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "state", null: false
    t.string "business_entity_type"
    t.integer "current_balance_cents", default: 0
    t.string "currency", null: false
    t.string "writeoff_type", null: false
    t.datetime "writeoff_date"
    t.integer "writeoff_interval"
    t.integer "discount_package_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "current_bonus_balance_cents", default: 0, null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "role_id"], name: "index_profiles_on_user_id_and_role_id", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "name", null: false
    t.boolean "read_only", null: false
    t.hstore "permissions", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_roles_on_client_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", null: false
    t.string "sms_token"
    t.datetime "sms_token_expired_at"
    t.datetime "sms_token_confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expired_at"
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "state", null: false
    t.string "password_digest"
    t.boolean "is_enabled_2fa", null: false
    t.string "email"
    t.datetime "email_confirmed_at"
    t.string "email_confirmation_code"
    t.datetime "email_confirmation_code_expired_at"
    t.string "phone"
    t.datetime "phone_confirmed_at"
    t.string "phone_confirmation_code"
    t.datetime "phone_confirmation_code_expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "password_reset_code"
    t.datetime "password_reset_code_expired_at"
    t.string "unconfirmed_phone"
    t.string "disable_2fa_confirmation_code"
    t.datetime "disable_2fa_confirmation_code_expired_at"
  end

end
