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
  organisation_id:,
  privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
  submission_email:,
  support_email: "your.email+fakedata84701@gmail.com.gov.uk",
  support_phone: "08000800",
  what_happens_next_markdown: "Test",
)
all_question_types_form.make_live!

root_question_1 = Question.create!(question_text: "What is your name?")
question_set = QuestionSet.create!(name: "What addresses have you lived at in the past 3 years?")
multiple_answers_question = Question.create!(question_text: "What countries have you travelled to in the past year?")

step1 = all_question_types_form.steps.create!(positionable: root_question_1, position: 1)
step2 = all_question_types_form.steps.create!(positionable: question_set, position: 2, min_answers: 1, max_answers:5)
step3 = all_question_types_form.steps.create!(positionable: multiple_answers_question, position: 3, min_answers:1, max_answers:10)

step1.update!(next_step: step2)
step2.update!(next_step: step3)

set_question_1 = Question.create!(question_text: "What was your address?")
set_question_2 = Question.create!(question_text: "What date did you start living at this address?")
set_question_3 = Question.create!(question_text: "What date did you stop living at this address?")

set_step1 = question_set.steps.create!(positionable: set_question_1, position: 1)
set_step2 = question_set.steps.create!(positionable: set_question_2, position: 2)
set_step3 = question_set.steps.create!(positionable: set_question_3, position: 3)

set_step1.update!(next_step: set_step2)
set_step2.update!(next_step: set_step3)

# Step.all.as_json(include: :positionable)
