# coding: utf-8
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pluggy/version'

Gem::Specification.new do |spec|
  spec.name         = 'pluggy'
  spec.version      = Pluggy::VERSION
  spec.authors      = ['thesecretmaster']
  spec.email        = ['thesecretmaster@developingtechnician.com']

  spec.summary      = 'This is the magic structure for you to plug all the ' \
                      'things into.'
  spec.description  = 'Pluggy lets you pick and choose a huge variety of ' \
                      'components and custimize every level of your webapp.'
  spec.homepage     = 'https://github.com/izwick-schachter/pluggy'
  spec.license      = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set
  # the 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',        '~> 1.15'
  spec.add_development_dependency 'guard',          '~> 2.14'
  spec.add_development_dependency 'guard-minitest', '~> 2.4'
  spec.add_development_dependency 'guard-rubocop',  '~> 1.3'
  spec.add_development_dependency 'minitest',       '~> 5.0'
  spec.add_development_dependency 'pry',            '~> 0.11'
  spec.add_development_dependency 'rake',           '~> 10.0'
  spec.add_development_dependency 'redcarpet',      '~> 3.4'
  spec.add_development_dependency 'rubocop',        '~> 0.52'
  spec.add_development_dependency 'yard',           '~> 0.9'

  spec.add_runtime_dependency 'faye-websocket', '~> 0.10'
  spec.add_runtime_dependency 'mustermann',     '~> 1.0'
  spec.add_runtime_dependency 'rack',           '~> 2.0'
end
