# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/hallmonitor/version'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "hallmonitor"
  gem.homepage = "http://github.com/epchris/hallmonitor"
  gem.license = "MIT"
  gem.summary = %Q{Simple Ruby Event Monitoring}
  gem.description = %Q{Hallmonitor is a simple event monitoring framework in Ruby}
  gem.email = "chris@tenharmsel.com"
  gem.authors = ["Chris TenHarmsel"]
  gem.executables = nil
  gem.version = Hallmonitor::Version::STRING
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hallmonitor #{Hallmonitor::Version::STRING}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
