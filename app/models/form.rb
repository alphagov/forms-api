class Form < ApplicationRecord
  has_many :pages

  validates :org, :name, presence: true

  def created_at
    attributes["created_at"].to_time.iso8601
  end

  def updated_at
    attributes["updated_at"].to_time.iso8601
  end
end
