require "sequel"
require "uri"
require_relative "./migrator"

class Database
  def self.existing_database
    database = Sequel.connect(ENV["DATABASE_URL"])
    database.extension :pg_json
    database.extension :pg_array
    database
  end

  def self.fresh_database
    url = URI.parse(ENV["DATABASE_URL"])
    database_name = url.path[1..]
    url.path = ""

    Sequel.connect(url.to_s) do |db|
      db.execute "DROP DATABASE IF EXISTS #{database_name}"
      db.execute "CREATE DATABASE #{database_name}"
    end

    database = Sequel.connect(ENV["DATABASE_URL"])
    database.extension :pg_json
    database.extension :pg_array
    migrator = Migrator.new
    migrator.destroy(database)
    migrator.migrate(database)
    database
  end
end
