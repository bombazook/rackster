require 'rackster/version'
require 'erb'
require 'sequel'
require 'sequel/extensions/migration'
require 'sequel_simple_callbacks'
require 'meander'
require 'yaml'
require 'rackster/configuration'
require 'rackster/tools'
require 'rackster/db'
require 'rack/app'

module Rackster
  extend Tools::Core
  autoload :Boot, 'rackster/boot'
end
