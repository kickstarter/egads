module Egads
  class Build < Group
    include Thor::Actions
    include LocalHelpers

    desc "[local] Compiles a deployable patch of the current commit and uploads it to S3"
    class_option :force, type: :boolean, aliases: '-f', default: false, banner: "Build and overwrite existing tarball on S3"
    class_option :seed, type: :boolean, default: false, banner: "Builds and tags a complete tarball for more efficient patches"
    class_option 'no-upload', type: :boolean, default: false, banner: "Don't upload the tarball to S3"
    argument :rev, type: :string, default: 'HEAD', desc: 'git revision to build'

    attr_accessor :build_sha

    def check_build
      say_status :rev, "#{rev} parsed to #{sha}"

      unless should_build?
        say_status :done, "#{build_type} tarball for #{sha} already exists. Pass --force to rebuild."
        exit 0
      end

      exit 1 unless can_build?
      say_status :build, "Making #{build_type} tarball for #{sha}", :yellow
    end

    def run_before_build_hooks
      run_hooks_for(:build, :before)
    end

    def write_revision_file
      File.open('REVISION', 'w') {|f| f << sha + "\n" }
    end

    def commit_extra_paths
      extra_paths = ["REVISION"]
      extra_paths += Config.build_extra_paths
      run_with_code("git add -f #{extra_paths * ' '} && git commit --no-verify -m 'egads build'")
      # Get the build SHA
      self.build_sha = run_with_code("git rev-parse --verify HEAD").strip
      run_with_code "git reset #{sha}" # Reset to original SHA

    end

    def make_tarball
      if options[:seed]
        # Seed tarball
        run_with_code "git archive #{build_sha} --output #{tarball.local_tar_path}"
      else
        # Patch tarball
        seed_ref = "refs/remotes/origin/#{Config.seed_branch}"
        # NB: the seed tarball is named after the parent of seed tag
        seed_parent = run_with_code("git rev-parse --verify #{seed_ref}^").strip
        File.open('egads-seed', 'w') {|f| f << seed_parent + "\n" }
        patch_files = [patch_path, 'egads-seed']
        run_with_code "git diff --binary #{seed_ref} #{build_sha} > #{patch_path}"
        run_with_code "tar -zcf #{tarball.local_tar_path} #{patch_files * ' '}"
        patch_files.each {|f| File.delete(f) }
      end

    end

    def run_after_build_hooks
      run_hooks_for(:build, :after)
    end

    def upload
      invoke(Egads::Upload, [sha], force: options[:force], seed: options[:seed]) unless options['no-upload']
    end

    def push_seed
      if options[:seed]
        run_with_code "git push -f origin #{build_sha}:refs/heads/#{Config.seed_branch}"
      end
    end

    module BuildHelpers
      def should_build?
        options[:force] || !tarball.exists?
      end

      def can_build?
        sha_is_checked_out? && working_directory_is_clean?
      end

      def sha_is_checked_out?
        head = run_with_code("git rev-parse --verify HEAD").strip
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
          "Stash your changes with `git stash -u` and try again."
        ]
      end

      def patch_path
        "#{sha}.patch"
      end

      def build_type
        options[:seed] ? 'seed' : 'patch'
      end

      def error(message)
        lines = Array(message)
        say_status :error, lines.shift, :red
        lines.each {|line| say_status '', line }

        false
      end
    end
    include BuildHelpers

  end
end
