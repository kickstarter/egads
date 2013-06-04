module Egads
  module Config

    TARBALL_EXTENSION = 'tar.gz'
    class << self
      def config_path
        path = ENV['EGADS_CONFIG'] || File.join(ENV['PWD'], 'egads.yml')
        unless path && File.readable?(path)
          raise ArgumentError.new("Could not read config file. Set either EGADS_CONFIG, or create egads.yml in the current directory")
        end
        path
      end

      def config
        @config ||= YAML.load_file(config_path)
      end

      def s3_bucket
        return @bucket if @bucket
        fog = Fog::Storage::AWS.new(aws_access_key_id: config['s3']['access_key'], aws_secret_access_key: config['s3']['secret_key'])
        @bucket ||= fog.directories.new(key: config['s3']['bucket'])
      end

      def s3_prefix
        config['s3']['prefix']
      end
    end
  end
end
