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
  validate :additional_guidance_fields

  def destroy_and_update_form!
    form = self.form
    destroy! && form.update!(question_section_completed: false)
  end

  def save_and_update_form
    return true unless has_changes_to_save?

    save!
    form.update!(question_section_completed: false)
    check_conditions.destroy_all if answer_type_changed_from_selection
    check_conditions.destroy_all if answer_settings_changed_from_only_one_option

    true
  end

  def next_page
    lower_item&.id
  end

  def as_json(options = {})
    options[:except] ||= [:next_page]
    options[:methods] ||= %i[next_page has_routing_errors]
    options[:include] ||= { routing_conditions: { methods: %i[validation_errors has_routing_errors] } }
    super(options)
  end

  def answer_type_changed_from_selection
    answer_type_previously_was&.to_sym == :selection && answer_type&.to_sym != :selection
  end

  def answer_settings_changed_from_only_one_option
    from_only_one_option = ActiveModel::Type::Boolean.new.cast(answer_settings_previously_was.try(:[], "only_one_option"))
    to_multiple_options = !ActiveModel::Type::Boolean.new.cast(answer_settings.try(:[], "only_one_option"))

    from_only_one_option && to_multiple_options
  end

  def has_routing_errors
    routing_conditions.filter(&:has_routing_errors).any?
  end

private

  def additional_guidance_fields
    if page_heading.present? && additional_guidance_markdown.blank?
      errors.add(:additional_guidance_markdown, "must be present when Page Heading is present")
    elsif additional_guidance_markdown.present? && page_heading.blank?
      errors.add(:page_heading, "must be present when Additional Guidance Markdown is present")
    end
  end
end
