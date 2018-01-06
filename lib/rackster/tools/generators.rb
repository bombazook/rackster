module Rackster
  module Generators; end
  module Tools
    module Generators # :nodoc:
      class << self
        def [] generator_name
          sources = find_generator(generator_name)
          sha = Rackster.sha_paths(sources)
          cname = const_name(generator_name)
          if sha_cache[generator_name] != sha
            if Rackster::Generators.const_defined?(cname)
              Rackster::Generators.send(:remove_const, cname)
            end
            const = load_from_scratch(generator_name, sources)
            sha_cache[generator_name] = sha
            const
          else
            generator_const generator_name
          end
        end

        private

        def sha_cache
          @sha_cache ||= {}
        end

        def find_generator(generator_name)
          wildcard = File.join('app/generators/**', "#{generator_file(generator_name)}.rb")
          Rackster.find_paths wildcard
        end

        def load_from_scratch generator_name, sources=[]
          i = 0
          while i < sources.size
            load sources[i]
            begin
              return generator_const(generator_name)
            rescue NameError
              i += 1
            end
          end
          raise Errors::ConstMissingError,
                "Expected #{sources} to define Rackster::Generators::#{const_name(generator_name)}"
        end

        def generator_file(generator_name)
          "#{Ext::String.underscore(generator_name)}_generator"
        end

        def generator_const(generator_name)
          Rackster::Generators.const_get const_name(generator_name)
        end

        def const_name generator_name
          Ext::String.camelize(generator_file(generator_name))
        end
      end

      def load_generator generator_name
        Generators[generator_name]
      end

      def invoke_generator generator_name, *arguments, **options, &block
        generator = load_generator(generator_name)
        generator.new(arguments, {:inline => true}.merge!(options)).invoke_all
      end
    end
  end
end
