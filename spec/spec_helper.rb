require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"
require "egads"

begin
  require 'pry'
rescue LoadError
end

Aws.config[:stub_responses] = true

SHA = 'deadbeef' * 5 # Test git sha

begin
  require 'debugger'
rescue LoadError
  puts "Skipping debugger"
end

# Extensions
class Minitest::Spec
  before do
    ENV['EGADS_CONFIG'] = "example/egads.yml"
    ENV['EGADS_REMOTE_CONFIG'] = "example/egads_remote.yml"

    # Clear stubbed responses
    Aws.config.delete(:s3)
  end

  after do
    ENV.delete('EGADS_CONFIG')
    ENV.delete('EGADS_REMOTE_CONFIG')
  end
end
