# -*- encoding: utf-8 -*-

require File.expand_path('../lib/sexptitah/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "sexptitah"
  gem.version       = Sexptitah::VERSION
  gem.summary       = %q{TODO: Summary}
  gem.description   = %q{TODO: Description}
  gem.license       = "MIT"
  gem.authors       = ["Alessandro Piras"]
  gem.email         = "laynor@gmail.com"
  gem.homepage      = "https://github.com/laynor/sexptitah#readme"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rspec_org_formatter', '~> 0.2.3'
end
