# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

submission_email = ENV["EMAIL"] || `git config --get user.email`.strip
organisation_id = 1 # Assumes you're using the default database seed for forms-admin

all_question_types_form = Form.create!(
  name: "All question types form",
  pages: [
    Page.create(
      question_text: "Single line of text",
      answer_type: "text",
      answer_settings: {
        input_type: "single_line",
      },
    ),
    Page.create(
      question_text: "Number",
      answer_type: "number",
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
    ),
    Page.create(
      question_text: "Email address",
      answer_type: "email",
    ),
    Page.create(
      question_text: "Todays Date",
      answer_type: "date",
      answer_settings: {
        input_type: "other_date",
      },
    ),
    Page.create(
      question_text: "National Insurance number",
      answer_type: "national_insurance_number",
    ),
    Page.create(
      question_text: "Phone number",
      answer_type: "phone_number",
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
  organisation_id:,
  privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
  submission_email:,
  support_email: "your.email+fakedata84701@gmail.com.gov.uk",
  support_phone: "08000800",
  what_happens_next_text: "Test",
)
all_question_types_form.make_live!
