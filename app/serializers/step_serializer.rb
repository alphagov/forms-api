class StepSerializer < ActiveModel::Serializer
  attributes :id, :next_step_id, :position, :min_answers, :max_answers
  attribute :positionable_type, key: :type

  has_one :positionable, key: :data
end
