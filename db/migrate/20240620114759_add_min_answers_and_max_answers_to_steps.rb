class AddMinAnswersAndMaxAnswersToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :min_answers, :integer
    add_column :steps, :max_answers, :integer
  end
end
