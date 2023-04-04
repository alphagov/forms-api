FactoryBot.define do
  factory :condition do
    routing_page { build :page }
    check_page { nil }
    goto_page { nil }
    answer_value { nil }
    skip_to_end { false }
  end
end
