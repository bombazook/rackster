module Rackster
  class App < Rack::App
    root_module = const_get Rackster.app_name
    mount root_module::Api::ApplicationController, to: '/'
  end
end
