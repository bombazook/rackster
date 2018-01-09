require 'rackster/tools/string'
require 'rackster/tools/paths'
require 'rackster/tools/generators'
require 'rackster/errors'
require 'logger'

module Rackster
  module Tools
    module Core
      include Tools::Paths
      include Tools::Generators

      DEFAULT_ENV_NAMES = %w[development test production].freeze

      def env_names
        @env_names ||= begin
          configured_envs = find_paths('config/environment/*').map do |i|
            i[/[^\/.]+(?=\.rb$)/]
          end
          configured_envs | DEFAULT_ENV_NAMES
        end
      end

      def env=(env)
        unless env_names.include?(env)
          raise UnexpectedConfig, 'environment not one of #{env_names}'
        end
        @env = env
      end

      def env
        @env ||= ([ENV['RACKSTER_ENV'].to_s] & env_names).first || 'development'
      end

      def app_name
        if @global_config
          global_config['app_name'] || Ext::String.camelize(File.basename(root))
        else
          Ext::String.camelize(File.basename(root))
        end
      end

      def env_key(key)
        RbNaCl::Util.hex2bin(ENV[key])
      end

      def global_config
        @global_config ||= begin
          default_global_config.deep_merge(full_configuration[env])
        end
      end

      def configure
        yield global_config
      end

      def logger
        @logger ||= begin
          logger_path = global_config.logger.path
          logger_dir = File.dirname(logger_path)
          FileUtils.mkdir_p(logger_dir) if File.exist?(tempdir_path)
          if File.exist?(logger_dir)
            FileUtils.touch logger_path
            Logger.new(logger_path, level: global_config.logger.level)
          else
            puts 'Logger unavavailable'
            nil
          end
        end
      end

      alias environment env
      alias environment= env=
      alias config global_config
      alias configuration global_config

      private

      def full_configuration
        unless root
          raise Errors::NoAppError, 'Please run app generator before use'
        end
        @full_configuration ||= load_full_config
      end

      def load_full_config
        db_config = load_config('database.yml')
        main_config = load_config
        db_config.each_key do |key|
          main_config[key] ||= {}
          main_config[key]['db'] = db_config[key]
        end
        main_config
      end

      def default_global_config
        @default_global_config ||= load_config('defaults.yml')
      end

      def load_config(file = 'config.yml')
        find_paths(file).inject(Configuration.new) do |cfg, config_file|
          erb = ERB.new(File.read(config_file)).result(binding)
          yml = YAML.safe_load(erb)
          yml ? cfg.deep_merge(yml) : cfg
        end
      end
    end
  end
end
