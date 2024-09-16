class Api::V2::FormDocument < ApplicationRecord
  belongs_to :form, class_name: "Api::V2::Form", optional: false

  validates :tag, presence: true
end
