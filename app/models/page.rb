class Page < ApplicationRecord
  belongs_to :form

  ANSWER_TYPES = %w[single_line number address date email national_insurance_number phone_number long_text selection organisation_name text].freeze

  validates :question_text, presence: true
  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }
end
