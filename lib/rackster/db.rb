module Rackster
  module Db # :nodoc:
    class << self
      def connection
        @connection ||=
          begin
            connection = Sequel.connect(db_config)
            connection.extension(:constraint_validations)
            connection
          end
      end

      def create
        check_for_configuration_errors
        check_for_adapter_errors
        build_db(db_path)
      end

      def migrate
        migrator.run
      end

      def pending_migrations?
        !migrator.is_current?
      end

      def migrator
        path = Rackster.find_path('db/migrations')
        Sequel::TimestampMigrator.new(connection, path)
      rescue Sequel::DatabaseConnectionError
        raise Errors::ManualSetupError, "configure db first"
      end

      private

      def db_config
        conf = Rackster.config.db.dup
        if sqlite? && Rackster.config.db.database != ':memory:'
          conf.database = db_path
        end
        conf.to_h
      end

      def check_for_configuration_errors
        configured? || raise(Errors::ConfigError, 'database not configured')
        sqlite? || raise(Errors::ManualSetupError, 'create database manually')
      end

      def check_for_adapter_errors
        new_sqlite_path? || raise(Errors::DbExists, "#{db_path} already exists")
      end

      def build_db(path)
        require 'sqlite3'
        SQLite3::Database.new(path)
        @connection = nil
        connection
      end

      def db_path
        @db_path ||= File.join(Rackster.root, Rackster.config.db.database)
      end

      def configured?
        !Rackster.config.db.database.nil? && !Rackster.config.db.adapter.nil?
      end

      def sqlite?
        Rackster.config.db.adapter == 'sqlite'
      end

      def new_sqlite_path?
        return false if Rackster.config.db.database == ':memory:'
        !File.exist?(db_path) && Rackster.subfolder?(Rackster.root, db_path)
      end
    end
  end
end
