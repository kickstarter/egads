require 'yaml'
require 'fog/aws'
require 'thor'
require 'benchmark'
require 'pathname'

module Egads; end

require 'egads/version'
require 'egads/config'
require 'egads/s3_tarball'
require 'egads/group'
require 'egads/command'
