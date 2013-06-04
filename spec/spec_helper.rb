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

class Minitest::Spec
end
