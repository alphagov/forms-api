class AddS3BucketNameToForms < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :s3_bucket_name, :string
  end
end
