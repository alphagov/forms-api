FactoryBot.define do
  factory :form do
    name { "MyText" }
    submission_email { "MyText" }
    org { "MyText" }
    live_at { "2022-12-16 11:29:45" }
    privacy_policy_url { "MyText" }
    form_slug { "MyText" }
    what_happens_next_text { "MyText" }
    support_email { "MyText" }
    support_phone { "MyText" }
    support_url_text { "MyText" }
    declaration_text { "MyText" }
    question_section_completed { false }
    declaration_section_completed { false }
    page_order { 1 }
  end
end
