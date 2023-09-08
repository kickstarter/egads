require "rubygems"
require "bundler/setup"
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

namespace :gem do
  require 'bundler/gem_tasks'

  @gem = "pkg/egads-#{ Egads::VERSION }.gem"

  desc "Push #{ @gem } to rubygems.org"
  task :push => %i[test build git:check] do
    sh %{gem push #{ @gem }}
  end
end

namespace :git do
  desc 'Check git workspace'
  task :check do
    sh %{git diff HEAD --quiet} do |ok|
      abort "\e[31mRefusing to continue - git workspace is dirty\e[0m" unless ok
    end
  end
end
