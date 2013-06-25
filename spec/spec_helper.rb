require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"
require "egads"

Fog.mock!

SHA = 'deadbeef' * 5 # Test git sha

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
      Egads::Config.s3_bucket.save # Ensure bucket exists

    end

    after do
      ENV.delete('EGADS_CONFIG')
      ENV.delete('EGADS_REMOTE_CONFIG')
    end

  end
end
