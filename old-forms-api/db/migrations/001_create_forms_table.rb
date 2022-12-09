Sequel.migration do
  change do
    create_table :forms do
      primary_key :id, type: :Bignum
      String :name
      String :submission_email
    end
  end
end
