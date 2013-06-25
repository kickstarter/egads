require 'yaml'
require 'fog'
require 'thor'
require 'benchmark'

module Egads; end

require 'egads/config'
require 'egads/s3_tarball'
require 'egads/group'
require 'egads/command'