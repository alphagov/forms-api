FactoryBot.define do
  factory :access_token do
    token_digest { Faker::Crypto.sha256 }
    owner { Faker::Name.first_name.underscore }
    deactivated_at { nil }
    description { nil }
    last_accessed_at { nil }
  end
end
