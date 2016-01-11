module Egads
  class S3Tarball
    attr_reader :sha, :remote, :seed
    def initialize(sha, options = {})
      @sha    = sha
      @remote = options[:remote]
      @seed   = options[:seed]
    end

    def config
      remote ? RemoteConfig : Config
    end

    def key
      [
        config.s3_prefix,
        seed ? 'seeds' : nil,
        "#{sha}.tar.gz"
      ].compact * '/'
    end

    def exists?
      bucket.object(key).exists?
    end

    def local_tar_path
      "tmp/#{sha}.tar.gz"
    end

    def upload(path=local_tar_path)
      File.open(path) {|f|
        bucket.put_object(key: key, body: f)
      }
    end

    # Write the S3 object's contents to a local file
    def download(file)
      bucket.object(key).get(response_target: file)
    end

    def bucket
      config.s3_bucket
    end
  end
end
