require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'
require './yard_tags'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

YARD::Rake::YardocTask.new(:yard)

task :default => :test
