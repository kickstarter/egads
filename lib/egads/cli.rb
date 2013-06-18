module Egads
  class CLI < Thor
    include Thor::Actions
    ##
    # Local commands

    desc "build", "[local] Compiles a deployable tarball of the current commit and uploads it to S3"
    method_option :force, type: :boolean, aliases: '-f', default: false, banner: "Build and overwrite existing tarball on S3"
    method_option 'no-upload', type: :boolean, default: false, banner: "Don't upload the tarball to S3"
    def build(rev='HEAD')
      sha = run_or_die("git rev-parse --verify #{rev}", capture: true).strip
      tarball = S3Tarball.new(sha)
      if !options[:force] && tarball.exists?
        say "Tarball for #{sha} already exists. Pass --force to rebuild."
        return
      end

      say "Building tarball for #{sha}..."
      # Check if we're on sha, if not, ask to check it out
      head = run_or_die("git rev-parse --verify HEAD", capture: true).strip
      unless head == sha
        say "** Error **"
        say "Trying to build #{sha[0,7]}, but #{head[0,7]} is checked out."
        say "Run `git checkout #{head[0,7]}` and try again."
        exit 1
      end

      # Ensure clean working directory
      unless run("git status -s", capture: true).empty?
        say "** Error **"
        say "Working directory is not clean."
        say "Stash your changes with `git add . && git stash` and try again."
        exit 1
      end

      # Make git archive
      FileUtils.mkdir_p(File.dirname(tarball.local_tar_path))
      run_or_die "git archive #{sha} --format=tar > #{tarball.local_tar_path}"

      # Write REVISION and add to tarball
      File.open('REVISION', 'w') {|f| f << sha + "\n" }
      run_or_die "tar -uf #{tarball.local_tar_path} REVISION"

      run_hooks_for(:build, :after)

      extra_paths = Config.build_extra_paths
      if extra_paths.any?
        run_or_die "tar -uf #{tarball.local_tar_path} #{extra_paths * " "}"
      end

      run_or_die "gzip -9f #{tarball.local_tar_path}"

      invoke(:upload, [sha], force: options[:force]) unless options['no-upload']
    end

    method_option :force, type: :boolean, aliases: '-f', default: false, banner: "Overwrite existing tarball on S3"
    desc "upload SHA", "[local, plumbing] Uploads a tarball for SHA to S3"
    def upload(sha)
      tarball = S3Tarball.new(sha)
      if !options[:force] && tarball.exists?
        say "Tarball for #{sha} already exists. Pass --force to upload again."
        return
      end

      path = tarball.local_gzipped_path
      size = File.size(path)

      say "Uploading tarball (%.1f MB)" % (size.to_f / 2**20)
      duration = Benchmark.realtime do
        tarball.upload(path)
      end
      say "Uploaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]

      File.delete(path)
    end

    ##
    # Remote commands

    desc "extract SHA", "[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem"
    method_option :force, type: :boolean, default: false, banner: "Overwrite existing files"
    def extract(sha)
      RemoteConfig.setup_environment
      dir = RemoteConfig.release_dir(sha)
      path = File.join(dir, "#{sha}.tar.gz")
      tarball = S3Tarball.new(sha, true)

      inside dir do
        if options[:force] || File.zero?(path) || !File.exists?(path)
          say "Downloading tarball"
          duration = Benchmark.realtime do
            File.open(path, 'w') {|f| f << tarball.contents }
          end
          size = File.size(path)
          say "Downloaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]
        else
          say "Tarball already downloaded. Use --force to overwrite"
        end

        # Check revision file to see if tarball is already extracted
        extract_flag_path = File.join(dir, '.egads-extract-success')
        if options[:force] || !File.exists?(extract_flag_path)
          say "Extracting tarball"
          run_or_die "tar -zxf #{path}"
        else
          say "Tarball already extracted. Use --force to overwrite"
        end
        FileUtils.touch(extract_flag_path)
      end
    end

    desc "stage SHA", "[remote] Readies SHA for release. If needed, generates URL for SHA and extracts"
    method_option :force, type: :boolean, default: false, banner: "Overwrite existing files"
    def stage(sha)
      RemoteConfig.setup_environment
      invoke(:extract, [sha], options)
      dir = RemoteConfig.release_dir(sha)
      stage_flag_path = File.join(dir, '.egads-stage-success')
      if options[:force] || !File.exists?(stage_flag_path)
        inside dir do
          run_hooks_for(:stage, :before)

          run_or_die("bundle install --deployment --quiet") if File.readable?("Gemfile")
          if shared_path = ENV['SHARED_PATH']
            symlink_directory File.join(shared_path, 'system'), File.join(dir, 'public', 'system')
            symlink_directory File.join(shared_path, 'log'), File.join(dir, 'log')

            # Symlink config files
            shared_config = File.join(shared_path, 'config')
            if File.directory?(shared_config)
              Dir.glob("#{shared_config}/*").each do |source|
                basename = File.basename(source)
                destination = File.join(dir, 'config', basename)
                symlink(source, destination)
              end
            end
          end

          run_hooks_for(:stage, :after)
        end
      else
        say "Already staged. Use --force to overwrite"
      end
      FileUtils.touch(stage_flag_path)
    end

    desc "release SHA", "[remote] Symlinks SHA to current and restarts services. If needed, stages SHA"
    method_option :force, type: :boolean, default: false, banner: "Overwrite existing files while staging"
    def release(sha)
      RemoteConfig.setup_environment
      invoke(:stage, [sha], options)
      dir = RemoteConfig.release_dir(sha)
      inside dir do
        run_hooks_for(:release, :before)
      end

      # destination of the current symlink
      current_release = File.readlink(RemoteConfig.release_to) rescue nil
      unless dir == current_release
        # Symlink this release to the release_to
        symlink_directory(dir, RemoteConfig.release_to) unless dir == current_release
      end

      inside RemoteConfig.release_to do
        # Restart services
        run_or_die(RemoteConfig.restart_command)
        run_hooks_for(:release, :after)
      end

      FileUtils.touch(dir) # Ensure this release isn't trimmed
      invoke(:trim, [4])
    end

    desc "trim N", "[remote, plumbing] Deletes old releases, keeping the N most recent (by mtime)"
    method_option :force, type: :boolean, default: false, banner: "No op, compatible with release"
    def trim(n=4)
      dirs = Dir.glob('*').sort_by{|path| File.mtime(path) }.reverse[n..-1].to_a
      dirs.each do |dir|
        say_status :trim, "Deleting #{dir}"
        FileUtils.rm_rf(dir)
      end
    end

    private
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

  end
end
