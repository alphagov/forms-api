class Page < ApplicationRecord
  has_paper_trail

  belongs_to :form
  has_many :routing_conditions, class_name: "Condition", foreign_key: "routing_page_id", dependent: :destroy
  has_many :check_conditions, class_name: "Condition", foreign_key: "check_page_id", dependent: :nullify
  has_many :goto_conditions, class_name: "Condition", foreign_key: "goto_page_id", dependent: :nullify
  acts_as_list scope: :form

  ANSWER_TYPES = %w[number address date email national_insurance_number phone_number selection organisation_name text name].freeze

  validates :question_text, presence: true
  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }

  def destroy_and_update_form!
    form = self.form
    destroy! && form.update!(question_section_completed: false)
  end

  def save_and_update_form
    return true unless has_changes_to_save?

    save!
    form.update!(question_section_completed: false)
    routing_conditions.destroy_all if answer_type_previously_was&.to_sym == :selection

    true
  end

  def next_page
    lower_item&.id
  end

  def as_json(options = {})
    options[:except] ||= [:next_page]
    options[:methods] ||= [:next_page]
    options[:include] ||= { routing_conditions: { methods: :validation_errors } }
    super(options)
  end
end
