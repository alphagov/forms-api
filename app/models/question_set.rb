class QuestionSet < ApplicationRecord
  has_many :steps, -> { order(position: :asc) }, class_name: "Step", foreign_key: "parent_question_set_id", dependent: :destroy
end
