class Repositories::ExampleRepository
  def test_query
    res = nil
    Database.use do |db|
      res = db.fetch("SELECT 1 as test").first
    end

    {
      result: res[:test]
    }
  end
end
