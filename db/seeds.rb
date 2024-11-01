# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

submission_email = ENV["EMAIL"] || `git config --get user.email`.strip

all_question_types_form = Form.create!(
  name: "All question types form",
  pages: [
    Page.create(
      question_text: "Single line of text",
      answer_type: "text",
      answer_settings: {
        input_type: "single_line",
      },
      is_optional: false,
    ),
    Page.create(
      question_text: "Number",
      answer_type: "number",
      is_optional: false,
    ),
    Page.create(
      question_text: "Address",
      answer_type: "address",
      answer_settings: {
        input_type: {
          international_address: false,
          uk_address: true,
        },
      },
      is_optional: false,
    ),
    Page.create(
      question_text: "Email address",
      answer_type: "email",
      is_optional: false,
    ),
    Page.create(
      question_text: "Todays Date",
      answer_type: "date",
      answer_settings: {
        input_type: "other_date",
      },
      is_optional: false,
    ),
    Page.create(
      question_text: "National Insurance number",
      answer_type: "national_insurance_number",
      is_optional: false,
    ),
    Page.create(
      question_text: "Phone number",
      answer_type: "phone_number",
      is_optional: false,
    ),
    Page.create(
      question_text: "Selection from a list of options",
      answer_type: "selection",
      answer_settings: {
        "only_one_option": "0", # TODO: investigate why we set this to "0"
        "selection_options": [
          { "name": "Option 1" },
          { "name": "Option 2" },
          { "name": "Option 3" },
        ],
      },
      is_optional: true, # Include an option for 'None of the above'
    ),
    Page.create(
      question_text: "Multiple lines of text",
      answer_type: "text",
      answer_settings: {
        input_type: "long_text",
      },
      is_optional: true,
    ),
  ],
  question_section_completed: true,
  declaration_text: "",
  declaration_section_completed: true,
  privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
  submission_email:,
  support_email: "your.email+fakedata84701@gmail.com.gov.uk",
  support_phone: "08000800",
  what_happens_next_markdown: "Test",
  share_preview_completed: true,
)
all_question_types_form.make_live!

e2e_s3_forms = Form.create!(
  name: "s3 submission test form",
  pages: [
    Page.create(
      question_text: "Single line of text",
      answer_type: "text",
      answer_settings: {
        input_type: "single_line",
      },
      is_optional: false,
    ),
  ],
  question_section_completed: true,
  declaration_text: "",
  declaration_section_completed: true,
  privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
  submission_email:,
  support_email: "your.email+fakedata84701@gmail.com.gov.uk",
  support_phone: "08000800",
  what_happens_next_markdown: "Test",
  share_preview_completed: true,
  submission_type: "s3",
  s3_bucket_region: "eu-west-2",
)
e2e_s3_forms.make_live!

branch_route_form = Form.create!(
  name: "Branch route form",
  pages: [
    Page.create(
      question_text: "How many times have you filled out this form?",
      answer_type: "selection",
      answer_settings: {
        only_one_option: "true",
        selection_options: [
          { "name": "Once" },
          { "name": "More than once" },
        ],
      },
      is_optional: false,
    ),
    Page.create(
      question_text: "What’s your name?",
      answer_type: "name",
      answer_settings: {
        input_type: "full_name",
        title_needed: false,
      },
      is_optional: false,
      is_repeatable: false,
    ),
    Page.create(
      question_text: "What’s your email address?",
      answer_type: "email",
      is_optional: false,
      is_repeatable: false,
    ),
    Page.create(
      question_text: "What was the reference of your previous submission?",
      answer_type: "text",
      answer_settings: {
        input_type: "single_line",
      },
      is_optional: false,
      is_repeatable: false,
    ),
    Page.create(
      question_text: "What’s your answer?",
      answer_type: "text",
      answer_settings: {
        input_type: "single_line",
      },
      is_optional: false,
      is_repeatable: false,
    ),
  ],
  question_section_completed: true,
  declaration_text: "",
  declaration_section_completed: true,
  privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
  submission_email:,
  support_email: "your.email+fakedata84701@gmail.com.gov.uk",
  support_phone: "08000800",
  what_happens_next_markdown: "Test",
  share_preview_completed: true,
)
Condition.create!(
  check_page: branch_route_form.pages.first,
  routing_page: branch_route_form.pages.first,
  goto_page: branch_route_form.pages.fourth,
  answer_value: "More than once",
)
Condition.create!(
  check_page: branch_route_form.pages.first,
  routing_page: branch_route_form.pages.third,
  goto_page: branch_route_form.pages.last,
  answer_value: nil,
)
branch_route_form.reload.make_live!
