require 'thor/group'
require 'pathname'
require 'fileutils'

module Rackster
  module Generators
    class RacksterGenerator < Thor::Group
      include Thor::Actions
      source_root File.expand_path('../templates/rackster', __FILE__)
      class_option :inline, aliases: ['-i', '-I'],
                            desc: 'Setup new project in current directory'
      argument :path, type: :string, desc: 'destination directory path',
                      required: false

      def setup_dir
        @current_dir = Rackster.pwd
        unless options[:inline]
          @current_dir = File.join(@current_dir, path)
          FileUtils.mkdir_p(@current_dir)
        end
      end

      def template_tree
        files = []
        Dir[File.join(RacksterGenerator.source_root, '**/*')].each do |entry|
          root = Pathname.new(RacksterGenerator.source_root)
          full_path = Pathname.new(entry)
          relative_path = full_path.relative_path_from root
          if File.directory?(entry)
            FileUtils.mkdir_p(File.join(@current_dir, relative_path))
          else
            files.push(path: entry, relative_path: relative_path)
          end
        end
        files.each do |file|
          template file[:path], File.join(@current_dir, file[:relative_path])
        end
      end

      def copy_migrations
        source_paths.each do |source_root|
          src_dir = File.join(source_root, 'db/migrations')
          dest_dir = File.join(@current_dir, 'db/migrations')
          Dir[File.join(src_dir, '**/*.rb')].each do |migration_path|
            filename = File.basename(migration_path)
            dest_file_path = File.join(dest_dir, filename)
            template migration_path, dest_file_path
          end
        end
      end
    end
  end
end
