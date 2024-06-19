class StepSerializer < ActiveModel::Serializer
  attributes :id, :next_step_id, :position
  attribute :positionable_type, key: :type

  has_one :positionable, key: :data
end
