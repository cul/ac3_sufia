# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'cul_ac3'
Rails.application.load_tasks

if defined?(RSpec)
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = ['--color', '--backtrace']
  end
end
