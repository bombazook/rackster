module Rackster
  module Tools
    module Ext
      module String
        def self.underscore(camel_cased_word)
          return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
          word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
          word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
          word.tr!("-".freeze, "_".freeze)
          word.downcase!
          word
        end

        def self.camelize(term)
          string = term.to_s
          string = string.sub(/^[a-z\d]*/) { |match| match.capitalize }
          string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
          string.gsub!("/".freeze, "::".freeze)
          string
        end
      end
    end
  end
end
