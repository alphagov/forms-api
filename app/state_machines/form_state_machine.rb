module FormStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    enum :state, {
      draft: "draft",
      live: "live",
    }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :live

      event :make_form_live do
        transitions from: :draft, to: :live, guard: Proc.new { task_status_service.mandatory_tasks_completed? }
      end

      event :make_changes_live do
        transitions from: :live, to: :draft, guard: Proc.new { has_live_version }
      end
    end

    private def task_status_service
      @task_status_service ||= TaskStatusService.new(form: self)
    end
  end
end
