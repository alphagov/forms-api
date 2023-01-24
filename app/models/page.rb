class Page < ApplicationRecord
  belongs_to :form
  acts_as_list scope: :form

  ANSWER_TYPES = %w[single_line number address date email national_insurance_number phone_number long_text selection organisation_name text name].freeze

  validates :question_text, presence: true
  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }

  def next_page
    lower_item&.id
  end

  def as_json(options = {})
    options[:except] ||= [:next_page]
    options[:methods] ||= [:next_page]
    super(options)
  end
end
