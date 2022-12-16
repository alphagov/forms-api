class Form < ApplicationRecord
  validates :org, :name, presence: true
end
