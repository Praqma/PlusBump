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

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|jenkins-pipeline)/})
  end

  spec.bindir        = "bin"
  spec.executables << 'plusbump'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_runtime_dependency 'docopt', "~> 0.6.1"
  spec.add_runtime_dependency 'rugged', "~> 0.26"
  spec.add_runtime_dependency 'semver', "~> 1.0"
end
