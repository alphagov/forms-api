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

ActiveRecord::Schema[7.0].define(version: 2022_12_16_112945) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forms", id: :bigint, default: nil, force: :cascade do |t|
    t.text "name"
    t.text "submission_email"
    t.text "org"
    t.datetime "created_at", precision: nil
    t.datetime "live_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "privacy_policy_url"
    t.text "form_slug"
    t.text "what_happens_next_text"
    t.text "support_email"
    t.text "support_phone"
    t.text "support_url"
    t.text "support_url_text"
    t.text "declaration_text"
    t.boolean "question_section_completed", default: false
    t.boolean "declaration_section_completed", default: false
    t.integer "page_order", array: true
  end

  create_table "schema_info", id: false, force: :cascade do |t|
    t.integer "version", default: 0, null: false
  end
end