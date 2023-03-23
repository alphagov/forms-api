FactoryBot.define do
  factory :made_live_form do
    association :form, :with_pages, :live
    json_form_blob { form.to_json(include: [:pages]) }
  end
end
