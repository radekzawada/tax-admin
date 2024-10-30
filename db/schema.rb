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

ActiveRecord::Schema[7.2].define(version: 2024_10_25_205200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "message_templates", force: :cascade do |t|
    t.string "template_name", null: false
    t.string "external_spreadsheet_id", null: false
    t.string "permitted_emails", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "url", null: false
    t.index ["external_spreadsheet_id"], name: "index_message_templates_on_external_spreadsheet_id", unique: true
    t.index ["name"], name: "index_message_templates_on_name", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "messages_package_dispatch_id", null: false
    t.string "recipient_email", null: false
    t.text "preview", null: false
    t.jsonb "variables", null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["messages_package_dispatch_id"], name: "index_messages_on_messages_package_dispatch_id"
  end

  create_table "messages_package_dispatches", force: :cascade do |t|
    t.bigint "messages_package_id", null: false
    t.string "status", null: false
    t.datetime "data_loaded_at"
    t.bigint "data_loaded_by_id"
    t.datetime "dispatched_at"
    t.bigint "dispatched_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_loaded_by_id"], name: "index_messages_package_dispatches_on_data_loaded_by_id"
    t.index ["dispatched_by_id"], name: "index_messages_package_dispatches_on_dispatched_by_id"
    t.index ["messages_package_id"], name: "index_messages_package_dispatches_on_messages_package_id"
  end

  create_table "messages_packages", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "message_template_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_sheet_id"
    t.index ["message_template_id"], name: "index_messages_packages_on_message_template_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fullname", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "messages", "messages_package_dispatches"
  add_foreign_key "messages_package_dispatches", "messages_packages"
  add_foreign_key "messages_package_dispatches", "users", column: "data_loaded_by_id"
  add_foreign_key "messages_package_dispatches", "users", column: "dispatched_by_id"
end
