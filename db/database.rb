require "sequel"

class Database
  def self.use
    database = Sequel.connect(ENV["DATABASE_URL"])
    database.extension :pg_json
    database.extension :pg_array
    yield(database)
  ensure
    database.disconnect
  end
end
