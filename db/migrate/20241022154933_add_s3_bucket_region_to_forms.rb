class AddS3BucketRegionToForms < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :s3_bucket_region, :string
  end
end
