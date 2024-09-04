# rubocop:disable Style/Documentation, Style/RaiseArgs, Style/RescueModifier
# frozen_string_literal: true

require 'aws-sdk-codedeploy'

module Egads
  class Release < Group
    include Egads::LocalHelpers
    include Thor::Actions

    desc '[remote] Symlinks SHA to current and restarts services. If needed, stages SHA'
    class_option :force, type: :boolean, default: false, banner: 'Overwrite existing release'
    class_option :deployment_id, type: :boolean, default: false, banner: 'Include deployment ID in release directory'
    argument :sha, type: :string, required: true, desc: 'git SHA to stage'

    def setup_environment
      RemoteConfig.setup_environment
    end

    def stage
      invoke(Egads::Stage, [sha], options)
    end

    def run_before_release_hooks
      return unless should_release?

      inside(dir) { run_hooks_for(:release, :before) }
    end

    def symlink_release
      return unless should_release?

      atomic_symlink(dir, release_to)
    end

    def restart
      return unless should_release?

      inside release_to do
        # Restart services
        run_with_code(RemoteConfig.restart_command, stream: true)
      end
    end

    def run_after_release_hooks
      inside release_to do
        run_hooks_for(:release, :after)
      end
    end

    def trim
      FileUtils.touch(dir) # Ensure this release isn't trimmed
      invoke(Egads::Trim, [4], {})
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

    # Symlinks src to dest, even if dest is an existing directory symlink
    # NB that `ln -f` doesn't work with directories.
    # Use an extra temporary symlink for atomicity (equivalent to `mv -T`)
    def atomic_symlink(src, dest)
      raise ArgumentError.new("#{src} is not a directory") unless File.directory?(src)

      say_status :symlink, "from #{src} to #{dest}"
      tmp = "#{dest}-new-#{rand(2**32)}"
      # Make a temporary symlink
      File.symlink(src, tmp)
      # Atomically rename the symlink, possibly overwriting an existing symlink
      File.rename(tmp, dest)
    end
  end
end

# rubocop:enable Style/Documentation, Style/RaiseArgs, Style/RescueModifier
