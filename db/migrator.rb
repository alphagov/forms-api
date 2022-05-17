require "sequel"

class Migrator
  def initialize
    Sequel.extension :migration
  end

  def destroy(database)
    Sequel::Migrator.run(database, "#{__dir__}/migrations", target: 0)
  end

  def migrate(database)
    Sequel::Migrator.run(database, "#{__dir__}/migrations")
  end
end
