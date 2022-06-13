Sequel.migration do
    change do
      create_table :pages do
        primary_key :id, type: :Bignum
        foreign_key :form_id, :forms, type: :Bignum
        String :question_text
        String :question_short_name
        String :hint_text
        String :answer_type
      end
    end
  end
  