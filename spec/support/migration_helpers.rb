module MigrationHelpers
  def migrate_to(version)
    migrations_paths = ActiveRecord::Migrator.migrations_paths
    migrations = ActiveRecord::MigrationContext.new(migrations_paths).migrations
    schema_migration = ActiveRecord::SchemaMigration

    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Migrator.new(:down, migrations, schema_migration, version).migrate
    end
  end
end
