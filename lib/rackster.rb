require 'yaml'
require 'erb'
require 'meander'
require 'rack/app'

require_relative 'rackster/version'
require_relative 'rackster/tools'

module Rackster
  extend Tools::Core
  autoload :Configuration, gem_path('rackster/configuration')
  autoload :Boot, gem_path('rackster/boot')
  autoload :Db, gem_path('rackster/db')
  autoload :App, gem_path('rackster/app')
end
