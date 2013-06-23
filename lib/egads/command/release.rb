module Egads
  class Release < Thor::Group
    include Thor::Actions

    desc "[remote] Symlinks SHA to current and restarts services. If needed, stages SHA"
    class_option :force, type: :boolean, default: false, banner: "Overwrite existing release"
    argument :sha, type: :string, required: true, desc: 'git SHA to stage'
    def setup_environment
      RemoteConfig.setup_environment
    end

    def stage
      invoke(:stage, [sha], options)
    end

    def run_before_release_hooks
      return unless should_release?
      inside(dir) { run_hooks_for(:release, :before) }
    end

    def symlink_release
      return unless should_release?
      symlink_directory(dir, release_to)
    end

    def restart
      return unless should_release?

      inside release_to do
        # Restart services
        run_with_code(RemoteConfig.restart_command)
      end
    end

    def run_after_release_hooks
      inside release_to do
        run_hooks_for(:release, :after)
      end
    end

    def trim
      FileUtils.touch(dir) # Ensure this release isn't trimmed
      invoke(:trim, [4], {})
    end

    protected
    def dir
      RemoteConfig.release_dir(sha)
    end

    def release_to
      RemoteConfig.release_to
    end

    def current_symlink_destination
      File.readlink(RemoteConfig.release_to) rescue nil
    end

    def should_release?
      @should_release = options[:force] || dir != current_symlink_destination unless defined?(@should_release)
      @should_release
    end
  end
end
