class AccessToken < ApplicationRecord
  validates :token_digest, :owner, presence: true

  scope :active, -> { where(deactivated_at: nil) }

  enum :permissions, {
    all: "all",
    readonly: "readonly",
  }, suffix: true, validate: true

  def generate_token
    users_token = SecureRandom.uuid
    self.token_digest = Digest::SHA256.hexdigest(users_token)
    users_token
  end

  def as_json(options = {})
    options[:except] ||= [:token_digest]
    super
  end
end
