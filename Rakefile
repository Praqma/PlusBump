require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Verbose test output'
task :doc do
  puts `rspec --format doc`
end

task :lint do
  puts `rubocop`
end
