require 'yaml'
require 'fog'
module Egads
  module Config
    class < self
      def config_path
        path = ENV['EGADS_CONFIG'] || File.join(ENV['PWD'], 'egads.yml')
        unless path && File.readable?(path)
          raise ArgumentError.new("Could not read config file. Set either EGADS_CONFIG, or create egads.yml in the current directory")
        end
        path
      end

      def config
        @config ||= YAML.load(config_path)
      end

      def s3_bucket
        return @bucket if @bucket
        fog = Fog::Storage::AWS.new(aws_access_key: config['s3']['access_key'], aws_secret_access_key:config['s3']['secret_key'])
        @bucket ||= fog.bucket.new(key: config['s3']['bucket']
      end
    end
  end
end
