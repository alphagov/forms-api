class AccessToken < ApplicationRecord
  validates :token, :owner, presence: true

  attr_accessor :users_token

  scope :active, -> { where(deactivated_at: nil) }

  before_validation :generate_users_token, :set_token

private

  def generate_users_token
    self.users_token = SecureRandom.uuid if users_token.blank?
  end

  def set_token
    self.token = Digest::SHA2.new(256).hexdigest(users_token)
  end
end
