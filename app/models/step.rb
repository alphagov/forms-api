class Step < ApplicationRecord
  belongs_to :positionable, polymorphic: true
  belongs_to :next_step, class_name: "Step", optional: true
  belongs_to :form, optional: true
  belongs_to :parent_question_set, class_name: "QuestionSet", optional: true
end
