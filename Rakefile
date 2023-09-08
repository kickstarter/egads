require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end
