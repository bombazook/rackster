require 'hashie/extensions/deep_merge'
module Rackster
  class Configuration < Meander::Mutable
    include Hashie::Extensions::DeepMerge
  end
end
