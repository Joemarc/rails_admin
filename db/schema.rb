# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150308025352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.integer  "user_id"
    t.integer  "postal_code_id"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.text     "street"
    t.string   "number"
    t.string   "interior_number"
    t.text     "between_streets"
    t.text     "colony"
    t.string   "state",                limit: nil
    t.float    "latitude"
    t.float    "longitude"
    t.string   "city",                 limit: nil
    t.text     "references"
    t.integer  "aliada_id"
    t.integer  "map_zoom"
    t.decimal  "references_latitude",              precision: 10, scale: 7
    t.decimal  "references_longitude",             precision: 10, scale: 7
  end

  add_index "addresses", ["postal_code_id"], name: "index_addresses_on_postal_code_id", using: :btree
  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "aliada_zones", force: true do |t|
    t.integer  "aliada_id"
    t.integer  "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "banned_aliada_users", force: true do |t|
    t.integer  "aliada_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "code_types", force: true do |t|
    t.integer  "value"
    t.string   "name",       limit: nil
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "code_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "code_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "code_users", ["code_id"], name: "index_code_users_on_code_id", using: :btree
  add_index "code_users", ["user_id"], name: "index_code_users_on_user_id", using: :btree

  create_table "codes", force: true do |t|
    t.integer  "user_id"
    t.integer  "code_type_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "codes", ["code_type_id"], name: "index_codes_on_code_type_id", using: :btree
  add_index "codes", ["user_id"], name: "index_codes_on_user_id", using: :btree

  create_table "conekta_cards", force: true do |t|
    t.string   "token"
    t.string   "last4"
    t.string   "exp_month"
    t.string   "exp_year"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "preauthorized"
    t.string   "customer_id"
    t.string   "brand"
    t.string   "name"
  end

  create_table "documents", force: true do |t|
    t.integer  "user_id"
    t.string   "file_file_name",    limit: nil
    t.string   "file_content_type", limit: nil
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "documents", ["user_id"], name: "index_documents_on_user_id", using: :btree

  create_table "extra_services", force: true do |t|
    t.integer  "extra_id"
    t.integer  "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extras", force: true do |t|
    t.string   "name",              limit: nil
    t.decimal  "hours",                         precision: 10, scale: 3
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
  end

  create_table "incomplete_services", force: true do |t|
    t.integer  "service_id"
    t.string   "email"
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "service_type_id"
    t.integer  "bathrooms"
    t.integer  "bedrooms"
    t.string   "date"
    t.string   "time"
    t.decimal  "estimated_hours",       precision: 10, scale: 3
    t.text     "street"
    t.string   "number"
    t.string   "interior_number"
    t.text     "between_streets"
    t.text     "colony"
    t.string   "state"
    t.string   "city"
    t.text     "extra_ids"
    t.integer  "map_zoom"
    t.string   "postal_code_number"
    t.decimal  "latitude",              precision: 10, scale: 7
    t.decimal  "longitude",             precision: 10, scale: 7
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "postal_code_not_found"
  end

  create_table "payment_methods", force: true do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "name",                  limit: nil
    t.string   "payment_provider_type"
    t.boolean  "disabled"
  end

  create_table "payment_provider_choices", id: false, force: true do |t|
    t.integer "payment_provider_id"
    t.integer "user_id"
    t.boolean "default"
    t.string  "payment_provider_type"
  end

  add_index "payment_provider_choices", ["user_id", "default"], name: "index_payment_provider_choices_on_user_id_and_default", unique: true, where: "(\"default\" = true)", using: :btree

  create_table "payments", force: true do |t|
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "payment_provider_id"
    t.decimal  "amount",                precision: 8, scale: 4
    t.string   "status"
    t.text     "api_raw_response"
    t.integer  "user_id"
    t.string   "payment_provider_type"
  end

  add_index "payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

  create_table "postal_codes", force: true do |t|
    t.string   "number",     limit: nil
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name"
    t.integer  "zone_id"
  end

  create_table "recurrences", force: true do |t|
    t.integer  "user_id"
    t.string   "status",      limit: nil
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "periodicity"
    t.integer  "aliada_id"
    t.string   "weekday",     limit: nil
    t.integer  "hour"
    t.integer  "total_hours"
    t.integer  "zone_id"
    t.string   "owner"
  end

  add_index "recurrences", ["user_id"], name: "index_recurrences_on_user_id", using: :btree

  create_table "schedules", force: true do |t|
    t.integer  "user_id"
    t.string   "status",     limit: nil
    t.datetime "datetime"
    t.integer  "service_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "aliada_id"
    t.integer  "zone_id"
  end

  add_index "schedules", ["service_id"], name: "index_schedules_on_service_id", using: :btree
  add_index "schedules", ["user_id"], name: "index_schedules_on_user_id", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.decimal  "value",      precision: 5, scale: 2
    t.integer  "aliada_id"
    t.text     "comment"
    t.integer  "service_id"
  end

  add_index "scores", ["service_id"], name: "index_scores_on_service_id", unique: true, using: :btree
  add_index "scores", ["user_id"], name: "index_scores_on_user_id", using: :btree

  create_table "service_types", force: true do |t|
    t.string   "name",           limit: nil
    t.integer  "periodicity"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "price_per_hour"
    t.string   "display_name",   limit: nil
    t.text     "benefits"
  end

  create_table "services", force: true do |t|
    t.integer  "zone_id"
    t.integer  "address_id"
    t.integer  "user_id"
    t.integer  "service_type_id"
    t.integer  "price"
    t.integer  "recurrence_id"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.decimal  "billed_hours",                               precision: 10, scale: 3
    t.decimal  "hours_before_service",                       precision: 10, scale: 3
    t.decimal  "hours_after_service",                        precision: 10, scale: 3
    t.integer  "bathrooms"
    t.integer  "bedrooms"
    t.text     "special_instructions"
    t.string   "status",                         limit: nil
    t.integer  "aliada_id"
    t.datetime "datetime"
    t.decimal  "estimated_hours",                            precision: 10, scale: 3
    t.text     "cleaning_supplies_instructions"
    t.text     "garbage_instructions"
    t.text     "attention_instructions"
    t.text     "equipment_instructions"
    t.text     "forbidden_instructions"
    t.time     "begin_time"
    t.time     "end_time"
    t.boolean  "entrance_instructions"
  end

  add_index "services", ["address_id"], name: "index_services_on_address_id", using: :btree
  add_index "services", ["recurrence_id"], name: "index_services_on_recurrence_id", using: :btree
  add_index "services", ["service_type_id"], name: "index_services_on_service_type_id", using: :btree
  add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree
  add_index "services", ["zone_id"], name: "index_services_on_zone_id", using: :btree

  create_table "table_extras_services", force: true do |t|
    t.integer "extra_id"
    t.integer "service_id"
  end

  create_table "tickets", force: true do |t|
    t.string   "classification",       limit: nil
    t.integer  "relevant_object_id"
    t.string   "relevant_object_type", limit: nil
    t.text     "message"
    t.string   "action_needed",        limit: nil
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "users", force: true do |t|
    t.string   "role",                   limit: nil
    t.string   "email",                  limit: nil
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.string   "phone",                  limit: nil
    t.string   "encrypted_password",     limit: nil,                         default: "", null: false
    t.string   "reset_password_token",   limit: nil
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                              default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "first_name",             limit: nil
    t.string   "last_name",              limit: nil
    t.string   "authentication_token",   limit: nil
    t.decimal  "credits",                            precision: 7, scale: 2
    t.string   "conekta_customer_id"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "zones", force: true do |t|
    t.string   "name",       limit: nil
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  Foreigner.load
  add_foreign_key "addresses", "postal_codes", name: "fk_rails_3b968378af"
  add_foreign_key "addresses", "users", name: "fk_rails_a782837e9d"

  add_foreign_key "code_users", "codes", name: "fk_rails_d334bd32db"
  add_foreign_key "code_users", "users", name: "fk_rails_640d8ad403"

  add_foreign_key "codes", "code_types", name: "fk_rails_0c2a23c77c"
  add_foreign_key "codes", "users", name: "fk_rails_8bca1f8d02"

  add_foreign_key "documents", "users", name: "fk_rails_57bac53f26"

  add_foreign_key "recurrences", "users", name: "fk_rails_bceec69f09"

  add_foreign_key "schedules", "services", name: "fk_rails_e91fec361b"
  add_foreign_key "schedules", "users", name: "fk_rails_4d5d3070ba"

  add_foreign_key "scores", "services", name: "scores_service_id_fk"
  add_foreign_key "scores", "users", name: "fk_rails_e93f40ca5b"

  add_foreign_key "services", "addresses", name: "fk_rails_3a3488bbe3"
  add_foreign_key "services", "recurrences", name: "fk_rails_21aee434ae"
  add_foreign_key "services", "service_types", name: "fk_rails_af1c273673"
  add_foreign_key "services", "users", name: "fk_rails_d48dde2778"
  add_foreign_key "services", "zones", name: "fk_rails_1fd6d13d7c"

end
