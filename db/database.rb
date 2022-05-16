require "sequel"
require_relative "./migrator"

class Database
  def self.use
    database = Sequel.connect(ENV["DATABASE_URL"])
    database.extension :pg_json
    database.extension :pg_array
    yield(database)
  ensure
    database.disconnect
  end

  def self.fresh_database(url, name)
    Sequel.connect(url) do |db|
      db.execute "DROP DATABASE IF EXISTS #{name}"
      db.execute "CREATE DATABASE #{name}"
    end

    database = Sequel.connect([url,name].join("/"))
    database.extension :pg_json
    database.extension :pg_array
    migrator = Migrator.new
    migrator.destroy(database)
    migrator.migrate(database)
    database
  end
end
