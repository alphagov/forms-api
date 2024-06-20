FactoryBot.define do
  factory :step do
    positionable { nil }
    next_step { nil }
    position { 1 }
    parent_question_set { nil }
  end
end
