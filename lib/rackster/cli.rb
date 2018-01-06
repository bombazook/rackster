require 'rubygems'
require 'bundler'
require 'thor'
require 'rackster'

module Rackster
  class Cli < Thor #:nodoc:

    shared_options = [
      :environment, {
        :type => :string,
        :aliases => ["-e"],
        :desc => "Rackster working environment"
      }
    ]

    no_tasks do
      def configure path=Dir.pwd
        Rackster.env = options[:environment] if options[:environment]
        Bundler.require(:default, Rackster.env.to_sym)
        Rackster.pwd = path
      end
    end

    desc 'version', 'show rackster version'
    def version
      say "Rackster #{VERSION}"
    end

    desc 'setup', 'setup environment'
    method_option *shared_options
    def setup
      configure
      say "Running migrations for #{Rackster.env} environment", :green
      Rackster::Db.migrator.run
      say "Success", :green
    end

    desc 'console', 'run current app console'
    method_option *shared_options
    def console
      configure
      say "Starting Rackster console in #{Rackster.env} environment", :green
      say "PWD is #{File.expand_path(Dir.pwd)}"
      Rackster::Boot.boot
      Pry.start(Rackster)
    end

    desc 'server', 'run rackster using your webserver'
    method_option *shared_options
    def server(*args)
      configure
      if File.exist?(Rackster.pwd)
        tempdir = FileUtils.mkdir_p(File.join(Rackster.pwd, 'tmp'))
        tmpl = File.join(Rackster.gem_root, 'lib/rackster/templates/config.ru.erb')
        erb = ERB.new(File.read(tmpl)).result(binding)
        tempfile = Tempfile.new(['config', '.ru'], tempdir)
        tempfile.write(erb)
        tempfile.close
        if Rackster.global_config.hot_reload == true
          args.push '-e', options[:environment] if options[:environment]
          system("shotgun #{tempfile.path} #{args.join(' ')}")
        else
          args.push '-E', options[:environment] if options[:environment]
          system("rackup #{tempfile.path} #{args.join(' ')}")
        end
      end
    end

    desc 'install', 'setup new authme env in pwd'
    def install(relative_path = 'rackster')
      Rackster.load_generator('rackster').new([relative_path], options).invoke_all
    end
  end
end
