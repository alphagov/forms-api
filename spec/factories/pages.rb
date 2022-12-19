FactoryBot.define do
  factory :page do
    question_text { Faker::Lorem.question }
    answer_type { Page::ANSWER_TYPES.sample }
    is_optional { nil }
    answer_settings { nil }
    form { build :form }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end
  end
end
