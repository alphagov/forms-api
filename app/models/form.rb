class Form < ApplicationRecord
  has_paper_trail

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  has_many :made_live_forms

  validates :org, :name, presence: true
  def start_page
    pages&.first&.id
  end

  def make_live!
    update!(live_at: Time.zone.now)

    made_live_forms.create!(json_form_blob: to_json(include: [:pages]))
  end

  def live_version
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

  # form_slug is always set based on name. This is here to allow Form
  # attributes to be updated easily based on json, without changning the value in the DB
  def form_slug=(slug); end
end
