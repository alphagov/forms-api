FactoryBot.define do
  factory :api_v2_form, class: "Api::V2::Form" do
    external_id { Faker::String.random(length: 8) }
  end
end
