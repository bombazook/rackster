module Rackster
  module Boot
    class << self
      def boot
        if Rackster.config.key? :db
          if Rackster::Db.pending_migrations?
            raise Errors::PendingMigrations, 'run Rackster setup first'
          end
          Rackster::Db.connection
        end
        load_environment_config
        require 'rack/app'
        require_sources
        load_initializers
        require 'rackster/app'
      end

      private

      def require_sources
        entry_point = 'app/api/application_controller.rb'
        Rackster.config.autoloaded_wildcards.unshift entry_point
        wildcards = Rackster.config.autoloaded_wildcards
        paths = Rackster.find_paths(*wildcards).uniq!
        Rackster.logger.debug 'Loaded files:'
        eager_require paths
      end

      def load_environment_config
        Rackster.find_paths("config/environment/#{Rackster.env}.rb").each do |config_path|
          require config_path
        end
      end

      def load_initializers
        Rackster.find_paths('config/initializers/*.rb').each do |initializer_path|
          require initializer_path
        end
      end

      def eager_require(paths)
        max_retries = paths.length
        retries = {}
        until paths.empty?
          path = paths.shift
          begin
            require path
            Rackster.logger.debug path
          rescue NameError => e
            retries[path] ||= 0
            if retries[path] >= max_retries
              Rackster.logger.error "Failed to load #{path} because of #{e.message}"
              raise Errors::LoadError
            end
            retries[path] += 1
            paths.push path
          end
        end
      end
    end
  end
end
