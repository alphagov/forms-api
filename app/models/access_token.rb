class AccessToken < ApplicationRecord
  validates :token, :owner, presence: true
end
