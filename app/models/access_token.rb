class AccessToken < ApplicationRecord
  validates :token_digest, :owner, presence: true
  validates :token_digest, uniqueness: { conditions: -> { active } }

  scope :active, -> { where(deactivated_at: nil) }

  def generate_token
    users_token = "forms_#{SecureRandom.uuid}"
    self.token_digest = Digest::SHA256.hexdigest(users_token)
    users_token
  end

  def as_json(options = {})
    options[:except] ||= [:token_digest]
    super
  end
end
