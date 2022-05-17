require "sequel"
require_relative "./migrator"

class Database
  def self.existing_database
    database = Sequel.connect(ENV["DATABASE_URL"])
    database.extension :pg_json
    database.extension :pg_array
    database
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
