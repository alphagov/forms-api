class Form < ApplicationRecord
  has_paper_trail

  include FormStateMachine

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  has_many :made_live_forms, -> { order(created_at: :asc) }, dependent: :destroy
  has_many :form_documents, dependent: :delete_all, class_name: "Api::V2::FormDocument"

  enum :submission_type, {
    email: "email",
    email_with_csv: "email_with_csv",
  }

  validates :name, presence: true
  validates :payment_url, url: true, allow_blank: true
  validate :marking_complete_with_errors
  validates :submission_type, presence: true

  scope :filter_by_creator_id, ->(creator_id) { where creator_id: }

  after_create :set_external_id

  def start_page
    pages&.first&.id
  end

  def has_draft_version
    draft? || live_with_draft? || archived_with_draft?
  end

  def draft_version
    snapshot.to_json
  end

  def live_at
    made_live_forms.last.created_at if made_live_forms.present?
  end

  def has_live_version
    live? || live_with_draft?
  end

  def has_been_archived
    archived? || archived_with_draft?
  end

  def live_version
    raise ActiveRecord::RecordNotFound unless has_live_version

    made_live_forms.last.json_form_blob
  end

  def archived_live_version
    raise ActiveRecord::RecordNotFound unless has_been_archived

    made_live_forms.last.json_form_blob
  end

  def name=(val)
    super(val)
    self[:form_slug] = name.parameterize
  end

  def as_json(options = {})
    options[:except] ||= [:external_id]
    options[:methods] ||= %i[live_at start_page has_draft_version has_live_version has_routing_errors ready_for_live incomplete_tasks task_statuses]
    super(options)
  end

  def snapshot(**kwargs)
    # override methods so it doesn't include things we don't want
    as_json(except: %i[state external_id],
            include: {
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

private

  def set_external_id
    update(external_id: id)
  end

  def task_status_service
    @task_status_service ||= TaskStatusService.new(form: self)
  end
end
