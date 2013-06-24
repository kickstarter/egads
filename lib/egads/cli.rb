module Egads
  class CLI < Thor
    include Thor::Actions

    require 'egads/command/build'
    require 'egads/command/upload'
    require 'egads/command/extract'
    require 'egads/command/stage'
    require 'egads/command/release'
    require 'egads/command/trim'

    register(Build, 'build', 'build [REV]', '[local] Compiles a deployable tarball of the current commit and uploads it to S3')
    register(Upload, 'upload', 'upload SHA', '[local, plumbing] Uploads a tarball for SHA to S3')
    register(Extract, 'extract', 'extract SHA', '[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem')
    register(Stage, 'stage', 'stage SHA', '[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem')
    register(Release, 'release', 'release SHA', '[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem')
    register(Trim, 'trime', 'trim [N]', "[remote, plumbing] Deletes old releases, keeping the N most recent (by mtime)")

    protected
    # Run command hooks from config file
    # E.g. run_hooks_for(:build, :after)
    def run_hooks_for(cmd, hook)
      say_status :hooks, "Running #{cmd} #{hook} hooks"
      Config.hooks_for(cmd, hook).each do |command|
        say "Running `#{command}`"
        run_or_die command
      end
    end

    # Symlinks a directory
    # NB that `ln -f` doesn't work with directories.
    # This is not atomic.
    def symlink_directory(src, dest)
      raise ArgumentError.new("#{src} is not a directory") unless File.directory?(src)
      say_status :symlink, "from #{src} to #{dest}"
      FileUtils.rm_rf(dest)
      FileUtils.ln_s(src, dest)
    end

    def symlink(src, dest)
      raise ArgumentError.new("#{src} is not a file") unless File.file?(src)
      say_status :symlink, "from #{src} to #{dest}"
      FileUtils.ln_sf(src, dest)
    end

    def release_dir
      RemoteConfig.release_dir(sha)
    end

  end
end
