# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kansuji/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["labocho"]
  gem.email         = ["labocho@penguinlab.jp"]
  gem.description   = %q{Convert numbers to/from Japanese Kansuji (number representation in Kanji)}
  gem.summary       = %q{Convert numbers to/from Japanese Kansuji (number representation in Kanji)}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "kansuji"
  gem.require_paths = ["lib"]
  gem.version       = Kansuji::VERSION
  gem.add_development_dependency "rspec", "~> 2.11.0"
  gem.add_development_dependency "guard-rspec"
end
