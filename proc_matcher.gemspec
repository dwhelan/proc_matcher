# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'proc_matcher/version'

Gem::Specification.new do |gem|
  gem.name          = 'proc_matcher'
  gem.version       = ProcMatcher::VERSION
  gem.authors       = ['Declan Whelan']
  gem.email         = ['dwhelan@leanintuit.com']

  gem.summary       = 'A matcher for testing proc and lambda equivalance.'
  gem.description   = 'A matcher for testing proc and lambda equivalance.'
  gem.homepage      = 'https://github.com/dwhelan/proc_matcher'
  gem.license       = 'MIT'

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'proc_extensions', '~> 0.1'

  gem.add_development_dependency 'bundler',     '~>  1.10'
  gem.add_development_dependency 'coveralls',   '~>  0.7'
  gem.add_development_dependency 'guard',       '~>  2.13'
  gem.add_development_dependency 'guard-rspec', '~>  4.6'

  if RUBY_VERSION =~ /2/
    gem.add_development_dependency 'pry-byebug', '~> 3.3'
  else
    gem.add_development_dependency 'pry-debugger', '~> 0.2'
  end

  gem.add_development_dependency 'rake',        '~> 10.0'
  gem.add_development_dependency 'rspec',       '~>  3.0'
  gem.add_development_dependency 'rspec-its',   '~>  1.1'
  gem.add_development_dependency 'rubocop',     '~>  0.30'
  gem.add_development_dependency 'simplecov',   '~>  0.9'
end
