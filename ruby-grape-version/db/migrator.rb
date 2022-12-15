require "sequel"

class Migrator
  def initialize
    Sequel.extension :migration
  end

  def destroy(database)
    migrate_to(database, 0)
  end

  def migrate(database)
    Sequel::Migrator.run(database, "#{__dir__}/migrations")
  end

  def migrate_to(database, version)
    Sequel::Migrator.run(database, "#{__dir__}/migrations", target: version)
  end
end
