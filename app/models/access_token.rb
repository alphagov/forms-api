class AccessToken < ApplicationRecord
  validates :token, :owner, presence: true

  scope :active, -> { where(deactivated_at: nil) }

  def generate_token
    users_token = SecureRandom.uuid
    self.token = Digest::SHA256.hexdigest(users_token)
    users_token
  end
end
