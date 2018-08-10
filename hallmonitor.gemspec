$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'hallmonitor/version'

Gem::Specification.new do |s|
  s.name = 'hallmonitor'
  s.version = Hallmonitor::Version::STRING

  s.authors = ['Chris TenHarmsel']
  s.summary = 'Simple Ruby Event Monitoring'
  s.description = 'Hallmonitor is a simple event monitoring framework in Ruby'
  s.email = ['chris@tenharmsel.com']
  s.homepage = 'http://github.com/epchris/hallmonitor'
  s.licenses = ['MIT']

  s.files = Dir['LICENSE.txt', 'README.md', 'lib/**/*.rb']
  s.test_files = Dir['spec/**/*.rb']
  s.require_path = 'lib'

  s.add_runtime_dependency('json', ['>= 0'])

  s.add_development_dependency('bundler', ['~> 1.3'])
  s.add_development_dependency('dogstatsd-ruby', ['>= 0'])
  s.add_development_dependency('influxdb', ['~> 0.2.2'])
  s.add_development_dependency('pry-byebug', ['>= 0'])
  s.add_development_dependency('rake', ['>= 0'])
  s.add_development_dependency('rdoc', ['>= 0'])
  s.add_development_dependency('rspec', ['>= 3.0'])
  s.add_development_dependency('yard', ['>= 0'])
  s.add_development_dependency('statsd-ruby', ['>= 0'])
end
