class FormSnapshotSerializer < ActiveModel::Serializer
  attributes :id, :name, :submission_email, :privacy_policy_url, :form_slug, :support_email, :support_phone, :support_url, :support_url_text, :declaration_text, :what_happens_next_markdown, :payment_url

  has_many :steps
end
