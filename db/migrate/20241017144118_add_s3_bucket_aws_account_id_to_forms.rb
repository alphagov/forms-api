class AddS3BucketAwsAccountIdToForms < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :s3_bucket_aws_account_id, :string
  end
end
