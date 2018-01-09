module Rackster
  module Tools
    module Configurable
      class << self
        def subsets
          @subsets ||= {}
        end
      end

      def self.included(base)
        base.extend ClassMethods
        base.set_subset
      end

      module ClassMethods
        def set_subset(key = nil)
          key ||= name.to_s.underscore
          key = key.split('/') if key.is_a? String
          Rackster::Utils::Configurable.subsets[self] = key
        end

        def config
          @config ||= begin
            keys = Rackster::Utils::Configurable.subsets[self]
            if keys
              value = Rackster.global_config
              for key in keys
                value = value[key]
              end
              value
            end
          end
        end
      end
    end
  end
end
