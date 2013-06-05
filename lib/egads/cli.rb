module Egads
  class CLI < Thor
    include Thor::Actions
    ##
    # Local commands

    desc "build", "[local] Compiles a deployable tarball of the current commit and uploads it to S3"
    method_option :force, type: :boolean, aliases: '-f', default: false, banner: "Build and overwrite existing tarball on S3"
    method_option 'no-upload', type: :boolean, default: false, banner: "Don't upload the tarball to S3"
    def build
      sha = run("git rev-parse --verify HEAD", capture: true).strip
      s3_tarball = S3Tarball.new(sha)
      if !options[:force] && s3_tarball.exists?
        say "Tarball for #{sha} already exists. Pass --force to rebuild."
        return
      end

      say "Building tarball for #{sha}..."
      # Ensure clean working directory
      unless run("git status -s", capture: true).empty?
        say "** Error **"
        say "Working directory is not clean."
        say "Run `git add .; git stash` and try again."
        exit 1
      end

      # Make git archive
      run_or_die "git archive #{sha} --format=tar > #{s3_tarball.local_tar_path}"

      # Write REVISION and add to tarball
      File.open('REVISION', 'w') {|f| f << sha + "\n" }
      run_or_die "tar -uf #{s3_tarball.local_tar_path} REVISION"

      run_hooks_for(:build, :post)

      extra_paths = Config.build_extra_paths
      if extra_paths.any?
        run_or_die "tar -uf #{s3_tarball.local_tar_path} #{extra_paths * " "}"
      end

      run_or_die "gzip -9f #{s3_tarball.local_tar_path}"

      invoke(:upload, [sha], force: options[:force]) unless options['no-upload']
    end

    method_options force: :boolean, aliases: '-f', default: false, banner: "Overwrite existing tarball on S3"
    desc "upload SHA", "[local, plumbing] Uploads a tarball for SHA to S3"
    def upload(sha)
      s3_tarball = S3Tarball.new(sha)
      if !options[:force] && s3_tarball.exists?
        say "Tarball for #{sha} already exists. Pass --force to upload again."
      end

      path = s3_tarball.local_gzipped_path
      size = File.size(path)

      say "Uploading tarball (%.1f MB)" % (size.to_f / 2**20)
      duration = Benchmark.realtime do
        s3_tarball.upload(path)
      end
      say "Uploaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]

      File.delete(path)
    end

    ##
    # Remote commands

    desc "extract URL", "[remote, plumbing] Downloads URL from S3 and extracts it to the filesystem"
    def extract(url)

    end

    desc "stage SHA", "[remote] Readies SHA for release. If needed, generates URL for SHA and extracts"
    def stage(sha)

    end

    desc "release SHA", "[remote] Symlinks SHA to current and restarts services. If needed, stages SHA"
    def release(sha)

    end

    desc "clean N", "[remote, plumbing] Deletes old releases, keeping the N most recent (by mtime)"
    def clean(n=4)
    end

    private
    # Run command hooks from config file
    # E.g. run_hooks_for(:build, :post)
    def run_hooks_for(cmd, hook)
      say_status :hooks, "Running #{build} #{hook} hooks"
      Config.hooks_for(cmd, hook).each do |command|
        say "Running `#{command}`"
        run_or_die command
      end
    end
  end
end
