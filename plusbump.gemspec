# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plusbump/version'

Gem::Specification.new do |spec|
  spec.name          = "plusbump"
  spec.version       = PlusBump::VERSION
  spec.authors       = ["Jan Krag", "Mads Nielsen"]
  spec.email         = ["jak@praqma.net", "man@praqma.net"]

  spec.summary       = %q{PlusBump ruby gem}
  spec.description   = %q{Use this gem to automate the automation of version bumping in git}
  spec.homepage      = "https://github.com/Praqma/PlusBump"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "bin"
  spec.executables << 'plusbump'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency 'docopt', "~> 0.6.1"
  spec.add_runtime_dependency 'rugged', "~> 0.24.6.1"
  spec.add_runtime_dependency 'semver', "~> 1.0.1"
end
