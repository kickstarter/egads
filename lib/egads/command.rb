module Egads
  class Command < Thor
    require 'egads/local_helpers'
    require 'egads/command/check'
    require 'egads/command/build'
    require 'egads/command/upload'
    require 'egads/command/extract'
    require 'egads/command/stage'
    require 'egads/command/release'
    require 'egads/command/trim'

    register(Check, 'check', 'check [REV]', '[local] Checks if a deployable tarball of the current commit already exists on S3')
    register(Build, 'build', 'build [REV]', '[local] Compiles a deployable tarball of the current commit and uploads it to S3')
    register(Upload, 'upload', 'upload SHA', '[local, plumbing] Uploads a tarball for SHA to S3')
    register(Extract, 'extract', 'extract SHA', '[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem')
    register(Stage, 'stage', 'stage SHA', '[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem')
    register(Release, 'release', 'release SHA', '[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem')
    register(Trim, 'trime', 'trim [N]', "[remote, plumbing] Deletes old releases, keeping the N most recent (by mtime)")

  end
end
