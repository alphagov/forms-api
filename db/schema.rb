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

ActiveRecord::Schema[7.1].define(version: 2024_08_01_123903) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.string "token_digest"
    t.string "owner"
    t.datetime "deactivated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_accessed_at"
    t.string "description"
  end

  create_table "conditions", force: :cascade do |t|
    t.bigint "check_page_id", comment: "The question page this condition looks at to compare answers"
    t.bigint "routing_page_id", comment: "The question page at which this conditional route takes place"
    t.bigint "goto_page_id", comment: "The question page which this conditions will skip forwards to"
    t.string "answer_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "skip_to_end", default: false
    t.index ["check_page_id"], name: "index_conditions_on_check_page_id"
    t.index ["goto_page_id"], name: "index_conditions_on_goto_page_id"
    t.index ["routing_page_id"], name: "index_conditions_on_routing_page_id"
  end

  create_table "forms", force: :cascade do |t|
    t.text "name"
    t.text "submission_email"
    t.text "privacy_policy_url"
    t.text "form_slug"
    t.text "support_email"
    t.text "support_phone"
    t.text "support_url"
    t.text "support_url_text"
    t.text "declaration_text"
    t.boolean "question_section_completed", default: false
    t.boolean "declaration_section_completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "creator_id"
    t.bigint "organisation_id"
    t.text "what_happens_next_markdown"
    t.string "state"
    t.string "payment_url"
    t.string "external_id"
    t.index ["external_id"], name: "index_forms_on_external_id", unique: true
  end

  create_table "made_live_forms", force: :cascade do |t|
    t.bigint "form_id"
    t.json "json_form_blob"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id"], name: "index_made_live_forms_on_form_id"
  end

  create_table "pages", force: :cascade do |t|
    t.text "question_text"
    t.text "hint_text"
    t.text "answer_type"
    t.integer "next_page"
    t.boolean "is_optional", null: false
    t.jsonb "answer_settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "form_id"
    t.integer "position"
    t.text "page_heading"
    t.text "guidance_markdown"
    t.boolean "is_repeatable", default: false, null: false
    t.index ["form_id"], name: "index_pages_on_form_id"
  end

  create_table "question_sets", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.string "question_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "steps", force: :cascade do |t|
    t.string "positionable_type", null: false
    t.bigint "positionable_id", null: false
    t.bigint "next_step_id"
    t.integer "position"
    t.bigint "parent_question_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["next_step_id"], name: "index_steps_on_next_step_id"
    t.index ["parent_question_set_id"], name: "index_steps_on_parent_question_set_id"
    t.index ["positionable_type", "positionable_id"], name: "index_steps_on_positionable"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "made_live_forms", "forms"
  add_foreign_key "pages", "forms"
  add_foreign_key "steps", "question_sets", column: "parent_question_set_id"
  add_foreign_key "steps", "steps", column: "next_step_id"
end
