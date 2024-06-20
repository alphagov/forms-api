class QuestionSetSerializer < ActiveModel::Serializer
  attributes :name

  has_many :steps
end
