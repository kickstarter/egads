$:.unshift 'lib'
require 'egads/version'

Gem::Specification.new do |s|
  s.name     = "egads"
  s.version  = Egads::VERSION
  s.summary  = "Extensible Git Archive Deploy Strategy"
  s.homepage = "https://github.com/kickstarter/egads"
  s.email    = ["aaron@ktheory.com"]
  s.authors  = ["Aaron Suggs"]
  s.license  = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.extra_rdoc_files  = ["README.md"]
  s.rdoc_options      = ["--charset=UTF-8"]

  s.add_dependency "aws-sdk-s3", '~> 1.0'
  s.add_dependency "rexml", ">= 3.3.4" # required for Ruby 3+
  s.add_dependency "thor"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"

  s.description = <<~EOS
    A collection of scripts for making a deployable tarball of a git commit,
    uploading it to Amazon S3, and downloading it to your servers.
  EOS
end
