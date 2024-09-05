# rubocop:disable Style/Documentation, Style/GuardClause
# frozen_string_literal: true

require 'aws-sdk-codedeploy'

module Egads
  class Stage < Group
    include Egads::LocalHelpers
    include Thor::Actions

    desc '[remote] Readies SHA for release. If needed, generates URL for SHA and extracts'
    class_option :force, type: :boolean, default: false, banner: 'Overwrite existing files'
    class_option :deployment_id, type: :boolean, default: false, banner: 'Include deployment ID in release directory'
    argument :sha, type: :string, required: true, desc: 'git SHA to stage'

    def setup_environment
      RemoteConfig.setup_environment
    end

    def extract
      invoke(Egads::Extract, [sha], options)
    end

    def run_before_hooks
      return unless should_stage?

      inside(dir) { run_hooks_for(:stage, :before) }
    end

    def bundle
      return unless should_stage?

      inside(dir) do
        run_with_code("bundle install #{RemoteConfig.bundler_options}", stream: true) if File.readable?('Gemfile')
      end
    end

    def symlink_system_paths
      return unless should_stage? && shared_path

      symlink_directory File.join(shared_path, 'system'), File.join(dir, 'public', 'system')
      symlink_directory File.join(shared_path, 'log'), File.join(dir, 'log')
    end

    def symlink_config_files
      return unless should_stage? && shared_path

      shared_config = File.join(shared_path, 'config')
      if File.directory?(shared_config)
        Dir.glob("#{shared_config}/*").each do |source|
          basename = File.basename(source)
          destination = File.join(dir, 'config', basename)
          symlink(source, destination)
        end
      end
    end

    def run_after_stage_hooks
      return unless should_stage?

      inside(dir) { run_hooks_for(:stage, :after) }
    end

    def mark_as_staged
      FileUtils.touch(stage_flag_path)
    end

    protected

    def dir
      base_dir = RemoteConfig.release_dir(sha)
      if options[:deployment_id]
        return "#{base_dir}_TEST"
      end
      base_dir
    end

    def stage_flag_path
      File.join(dir, '.egads-stage-success')
    end

    def should_stage?
      options[:force] || !File.exist?(stage_flag_path)
    end

    def shared_path
      ENV['SHARED_PATH']
    end
  end
end

# rubocop:enable Style/Documentation, Style/GuardClause
