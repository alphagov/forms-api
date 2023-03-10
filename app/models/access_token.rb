class AccessToken < ApplicationRecord
  validates :token, :owner, presence: true

  scope :active, -> { where(deactivated_at: nil) }
end
