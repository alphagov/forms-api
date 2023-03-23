class Form < ApplicationRecord
  has_paper_trail

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  has_many :made_live_forms, dependent: :destroy

  validates :org, :name, presence: true
  def start_page
    pages&.first&.id
  end

  def make_live!
    update!(live_at: Time.zone.now)

    made_live_forms.create!(json_form_blob: snapshot.to_json)
  end

  def draft_version
    snapshot.to_json
  end

  def live_version
    return draft_version if made_live_forms.blank?

    made_live_forms.last.json_form_blob
  end

  def name=(val)
    super(val)
    self[:form_slug] = name.parameterize
  end

  def as_json(options = {})
    options[:methods] ||= [:start_page]
    super(options)
  end

  def snapshot
    # override methods so it doesn't include things we don't want
    as_json(include: [:pages], methods: [:start_page])
  end

  # form_slug is always set based on name. This is here to allow Form
  # attributes to be updated easily based on json, without changning the value in the DB
  def form_slug=(slug); end
end
