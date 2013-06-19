require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"
require "egads"

Fog.mock!

begin
  require 'debugger'
rescue LoadError
  puts "Skipping debugger"
end

# Extensions
class Minitest::Spec

  def self.setup_configs!
    before do
      ENV['EGADS_CONFIG'] = "example/egads.yml"
      ENV['EGADS_REMOTE_CONFIG'] = "example/egads_remote.yml"
    end

    after do
      ENV.delete('EGADS_CONFIG')
      ENV.delete('EGADS_REMOTE_CONFIG')
    end

  end
end
