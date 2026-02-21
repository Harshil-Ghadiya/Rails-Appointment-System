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

ActiveRecord::Schema[8.1].define(version: 2026_02_20_045409) do
  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "organization_id"
    t.string "patient_address"
    t.string "patient_email"
    t.string "patient_name"
    t.string "patient_phone"
    t.integer "status"
    t.string "token_number"
    t.integer "token_number_only"
    t.datetime "updated_at", null: false
    t.index ["token_number_only"], name: "index_appointments_on_token_number_only"
  end

  create_table "booking_controls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "day_name"
    t.time "end_time"
    t.integer "organization_id"
    t.time "start_time"
    t.string "token_prefix"
    t.datetime "updated_at", null: false
  end

  create_table "field_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_name"
    t.boolean "is_required"
    t.integer "organization_id"
    t.datetime "updated_at", null: false
  end

  create_table "notices", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "notice_type"
    t.integer "organization_id"
    t.integer "status"
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "doctor_status"
    t.string "email"
    t.boolean "is_approved"
    t.boolean "is_booking_stopped"
    t.string "name"
    t.string "phone_number"
    t.datetime "updated_at", null: false
  end

  create_table "reserved_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "organization_id"
    t.integer "token_number"
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.text "address"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_phone_verified"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name"
    t.integer "organization_id"
    t.string "otp_code"
    t.string "password_digest"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end
end
