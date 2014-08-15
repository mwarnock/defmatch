# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'defmatch/version'

Gem::Specification.new do |spec|
  spec.name          = "defmatch"
  spec.version       = Defmatch::VERSION
  spec.authors       = ["Max Warnock"]
  spec.email         = ["mwarnock@analytical.info"]
  spec.summary       = %q{Defmatch provides a method for classes to define and dispatch methods off of pattern matching.}
  spec.description   = %q{Switching between erlang and ruby a fair amount has me missing erlang's function definition features. Particularly dispatching based on pattern matching. Defmatch is my way of bringing some of that functionality into ruby.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
