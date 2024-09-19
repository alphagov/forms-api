FactoryBot.define do
  factory :form_document, class: "Api::V2::FormDocument" do
    form { association :api_v2_form }
    tag { :draft }
  end
end
