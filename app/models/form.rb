class Form < ApplicationRecord
  has_many :pages, -> { order(position: :asc) }, dependent: :destroy

  validates :org, :name, presence: true
  def start_page
    pages&.first&.id
  end

  def make_live!
    update!(live_at: Time.zone.now)
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
