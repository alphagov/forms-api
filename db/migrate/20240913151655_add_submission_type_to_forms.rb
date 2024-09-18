class AddSubmissionTypeToForms < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :submission_type, :string, null: false, default: "email"
  end
end
