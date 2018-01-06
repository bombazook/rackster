
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rackster/version"

Gem::Specification.new do |spec|
  spec.name          = "rackster"
  spec.version       = Rackster::VERSION
  spec.authors       = ["Kostrov Alexander"]
  spec.email         = ["bombazook@gmail.com"]

  spec.summary       = %q{ Small rack-app skeleton gem }
  spec.description   = %q{ Small rack-app skeleton gem with rails-like structure}
  spec.homepage      = "https://github.com/bombazook/rackster"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'meander'
  spec.add_runtime_dependency 'prototok'

  spec.add_runtime_dependency 'hashie'
  spec.add_runtime_dependency 'rack-app'
  spec.add_runtime_dependency 'sequel'
  spec.add_runtime_dependency 'sequel_simple_callbacks'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'database_cleaner'
end
