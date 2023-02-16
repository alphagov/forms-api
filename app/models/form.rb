class Form < ApplicationRecord
  if FeatureService.enabled?(:draft_live_versioning)
    has_paper_trail ignore: :live_at
  end

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy, autosave: true

  validates :org, :name, presence: true

  def make_live!
    self.update!(live_at: Time.zone.now)

    if FeatureService.enabled?(:draft_live_versioning)
      self.paper_trail_event = :published
      self.touch
    end
  end

  def live_version
    if FeatureService.enabled?(:draft_live_versioning)
      live_form = self.versions.where(event: :published).last
      if live_form
        live_form.reify(has_many: true)
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def start_page
    pages&.first&.id
  end

  def make_live!
    update!(live_at: Time.zone.now)

    if FeatureService.enabled?(:draft_live_versioning)
      form.paper_trail_event = :published
      form.touch
    end
  end

  def live_version
    snapshot
  end

  def snapshot
    to_json(include: [:pages])
  end

  def name=(val)
    super(val)
    self[:form_slug] = name.parameterize
  end

  def as_json(options = {})
    options[:methods] ||= [:start_page]
    super(options)
  end

  # form_slug is always set based on name. This is here to allow Form
  # attributes to be updated easily based on json, without changning the value in the DB
  def form_slug=(slug); end
end
