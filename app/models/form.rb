require_relative "../state_machines/form_state_machine"
class Form < ApplicationRecord
  include FormStateMachine

  has_paper_trail

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  has_many :made_live_forms, -> { order(created_at: :asc) }, dependent: :destroy

  validates :name, presence: true
  validate :marking_complete_with_errors

  scope :filter_by_organisation_id, ->(organisation_id) { where organisation_id: }
  scope :filter_by_creator_id, ->(creator_id) { where creator_id: }

  def start_page
    pages&.first&.id
  end

  def make_live!(live_at = nil)
    live_at ||= Time.zone.now
    touch(time: live_at)

    form_blob = snapshot(live_at:)
    made_live_forms.create!(json_form_blob: form_blob.to_json, created_at: live_at)
  end

  def has_draft_version
    return true if made_live_forms.blank?

    updated_at > live_at
  end

  def draft_version
    snapshot.to_json
  end

  def live_at
    made_live_forms.last.created_at if made_live_forms.present?
  end

  def has_live_version
    made_live_forms.present?
  end

  def live_version
    raise ActiveRecord::RecordNotFound if made_live_forms.blank?

    made_live_forms.last.json_form_blob
  end

  def name=(val)
    super(val)
    self[:form_slug] = name.parameterize
  end

  def as_json(options = {})
    options[:methods] ||= %i[live_at start_page has_draft_version has_live_version has_routing_errors ready_for_live incomplete_tasks task_statuses]
    super(options)
  end

  def snapshot(**kwargs)
    # override methods so it doesn't include things we don't want
    as_json(include: {
      pages: {
        include: {
          routing_conditions: { methods: :validation_errors },
        },
      },
    }, methods: [:start_page]).merge(kwargs)
  end

  # form_slug is always set based on name. This is here to allow Form
  # attributes to be updated easily based on json, without changning the value in the DB
  def form_slug=(slug); end

  def has_routing_errors
    pages.filter(&:has_routing_errors).any?
  end

  def marking_complete_with_errors
    errors.add(:base, :has_validation_errors, message: "Form has routing validation errors") if question_section_completed && has_routing_errors
  end

  def ready_for_live
    task_status_service.mandatory_tasks_completed?
  end

  delegate :incomplete_tasks, to: :task_status_service

  delegate :task_statuses, to: :task_status_service

  def make_unlive!
    made_live_forms.destroy_all
  end

private

  def task_status_service
    @task_status_service ||= TaskStatusService.new(form: self)
  end
end
