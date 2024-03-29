module Egads

  module CommonConfig
    def config
      @config ||= YAML.load_file(config_path)
    end

    def s3_bucket
      @bucket ||= begin
        client = Aws::S3::Client.new(**{
          access_key_id:     config['s3']['access_key'],
          secret_access_key: config['s3']['secret_key'],
          region:            config['s3']['region'],
        }.compact)
        Aws::S3::Bucket.new(config['s3']['bucket'], client: client)
      end
    end

    def s3_prefix
      config['s3']['prefix']
    end

  end

  # Local config in the tarball or current working directory
  module Config
    extend CommonConfig

    def self.config_path
      path = ENV['EGADS_CONFIG'] || File.join(Dir.pwd, 'egads.yml')
      unless path && File.readable?(path)
        raise ArgumentError.new("Could not read config file. Set either EGADS_CONFIG, or create egads.yml in the current directory")
      end
      path
    end

    # Returns the hooks in the config for cmd and hook.
    # E.g. hooks_for(:build, :post)
    def self.hooks_for(cmd, hook)
      if Hash === config[cmd.to_s]
        Array(config[cmd.to_s][hook.to_s])
      else
        []
      end
    end

    def self.build_extra_paths
      config['build'] && Array(config['build']['extra_paths'])
    end

    def self.seed_branch
      config['seed_branch'] || "egads-seed"
    end
  end

  # Remote config for the extract command (before data in tarball is available)
  module RemoteConfig
    extend CommonConfig

    def self.config_path
      path = ENV['EGADS_REMOTE_CONFIG'] || "/etc/egads.yml"
      unless path && File.readable?(path)
        raise ArgumentError.new("Could not read remote config file. Set either EGADS_REMOTE_CONFIG, or create /etc/egads.yml")
      end
      path
    end

    def self.release_to
      config['release_to']
    end

    def self.extract_to
      config['extract_to']
    end

    def self.seed_dir
      config['cache_seeds_to']
    end

    def self.release_dir(sha)
      File.join(config['extract_to'], sha)
    end

    # Set environment variables from the config
    def self.setup_environment
      config['env'].each{|k,v| ENV[k] = v.to_s } if config['env']
    end

    def self.restart_command
      config['restart_command']
    end

    def self.bundler_options
      config['bundler']['options'] if config['bundler']
    end
  end
end
