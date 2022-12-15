class Repositories::ExampleRepository
  def initialize(database)
    @database = database
  end

  def test_query(name, email)
    id = @database[:forms].insert(name:, submission_email: email)
    created_form = @database[:forms].where(id:).first

    {
      result: created_form
    }
  end
end
