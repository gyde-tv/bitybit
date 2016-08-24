# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitybit/version'

Gem::Specification.new do |spec|
  spec.name          = "bitybit"
  spec.version       = Bitybit::VERSION
  spec.authors       = ["Darcy Laycock"]
  spec.email         = ["darcy@gyde.tv"]

  spec.summary       = %q{Redis-based search and indexing for Ruby}
  spec.description   = %q{Bitmap index tooling and interfaces for Ruby applications. Uses Redis as your backend data store.}
  spec.homepage      = "https://github.com/gyde-tv/bitybit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'bitwise'
  spec.add_dependency 'fast_bitset'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
