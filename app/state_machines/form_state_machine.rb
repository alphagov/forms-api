module FormStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    enum :state, {
      draft: "draft",
      live: "live",
      draft_live: "draft_live",
      archived: "archived",
      draft_archived: "draft_archived"
    }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :live
      state :draft_live
      state :archived
      state :draft_archived

      event :make_form_live do
        transitions from: :draft, to: :live, guard: Proc.new { task_status_service.mandatory_tasks_completed? }
      end

      event :draft_new_live_form do
        transitions from: :live, to: :draft_live, guard: Proc.new { has_live_version }
      end

      event :make_draft_changes_live do
        transitions from :draft_live, to: :live
      end

      event :archive_live_form do
        # TODO: Is this only if a form is live and no draft or could a live form be archived even if there is an existing draft?
        transitions from :live, to: :archived
      end

      event :create_draft_from_archived_form do
        transitions from: :archived, to: :draft_archived
      end

    end

    private def task_status_service
      @task_status_service ||= TaskStatusService.new(form: self)
    end
  end
end
