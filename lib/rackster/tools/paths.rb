require 'digest/sha2'

module Rackster
  module Tools
    module Paths
      attr_writer :pwd

      def pwd
        @pwd ||= Dir.pwd
      end

      def root(path = nil)
        path ||= @pwd || Dir.pwd
        path = Pathname.new(path)
        gemfile_pathname = Pathname.new('Gemfile')
        loop do
          if path.entries.include? gemfile_pathname
            return path
          else
            path = path.parent
            return nil if path.parent == path
          end
        end
      end

      def tempdir_path
        if @global_config.nil?
          File.join(root, 'tmp')
        else
          @tempdir_path ||= begin
            if Rackster.config.key? :tempdir_path
              Rackster.config.tempdir_path
            else
              File.join(root, 'tmp')
            end
          end
        end
      end

      def load_paths
        paths = [gem_path('rackster/default_app'), root].compact
        paths += (config['load_paths'] || []) if @configuration
        paths
      end

      def find_paths(*subpaths)
        path_product = load_paths.product(subpaths).map do |i|
          File.join(*i)
        end
        enum = Dir[*path_product]
        if block_given?
          enum.each { |i| yield i }
        else
          enum.entries
        end
      end

      def find_path(*subpaths)
        find_paths(*subpaths).first
      end

      def subfolder?(folder, path)
        f = File.expand_path(folder)
        p = File.expand_path(path)
        p.include?(f)
      end

      def sha_paths(*paths)
        paths.flatten.map { |i| Digest::SHA256.hexdigest(File.read(i)) }
      end

      def gem_root
        Gem::Specification.find_by_name('rackster').gem_dir
      end

      def gem_path(path = '')
        File.join(gem_root, 'lib', path)
      end
    end
  end
end
