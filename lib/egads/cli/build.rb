module Egads
  class CLI

    desc "build", "[local] Compiles a deployable tarball of the current commit and uploads it to S3"
    method_option :force, type: :boolean, aliases: '-f', default: false, banner: "Build and overwrite existing tarball on S3"
    method_option 'no-upload', type: :boolean, default: false, banner: "Don't upload the tarball to S3"

    attr_reader :rev
    def build(rev='HEAD')
      @rev = rev
      return unless should_build?
      say_status :rev, "#{rev} parsed to #{sha}"
      exit 1 unless can_build?

      # Do build
      say_status :build, "Making tarball for #{sha}", :yellow
      make_git_archive
      append_revision_file
      run_hooks_for(:build_after)
      append_extra_paths
      gzip_archive

      invoke(:upload, [sha]) unless options['no-upload']
    end


    private
    def sha
      @sha ||= run_with_code("git rev-parse --verify #{rev}").strip
    end

    def short_sha
      sha[0,7]
    end

    def tarball
      @tarball ||= S3Tarball.new(sha)
    end

    def should_build?
      if !options[:force] && tarball.exists?
        say_status :done "Tarball for #{sha} already exists. Pass --force to rebuild."
        true
      end
    end

    def can_build?
      sha_is_checked_out? && working_directory_is_clean?
    end

    def sha_is_checked_out?
      head = run_with_code("git rev-parse --verify HEAD", capture: true).strip
      short_head = head[0,7]
      head == sha or error [
        "Cannot build #{short_sha} because #{short_head} is checked out.",
        "Run `git checkout #{short_sha}` and try again"
      ]
    end

    def working_directory_is_clean?
      run("git status -s", capture: true).empty? or
      error [
        "Cannot build #{short_sha} because the working directory is not clean.",
        "Stash your changes with `git add . && git stash` and try again."
      ]
    end

    def make_git_archive
      FileUtils.mkdir_p(File.dirname(tarball.local_tar_path))
      run_with_code "git archive #{sha} --format=tar > #{tarball.local_tar_path}"
    end

    def append_revision_file
      File.open('REVISION', 'w') {|f| f << sha + "\n" }
      run_with_code "tar -uf #{tarball.local_tar_path} REVISION"
    end

    def append_extra_paths
      extra_paths = Config.build_extra_paths
      if extra_paths.any?
        run_with_code "tar -uf #{tarball.local_tar_path} #{extra_paths * " "}"
      end
    end

    def gzip_archive
      run_with_code "gzip -9f #{tarball.local_tar_path}"
    end

    def error(message)
      lines = Array(message)
      say_status :error, lines.shift, :red
      lines.each {|line| say_status '', line }

      false
    end

  end
end
