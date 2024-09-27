FactoryBot.define do
  factory :api_v2_form, class: "Api::V2::Form" do
    external_id { Faker::Alphanumeric.alphanumeric(number: 8) }
  end
end
