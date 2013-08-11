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
      bucket.files.head(key)
    end

    def local_tar_path
      "tmp/#{sha}.tar.gz"
    end

    def upload(path=local_tar_path)
      File.open(path) {|f|
        bucket.files.create(key: key, body: f)
      }
    end

    # Load the file contents from S3
    def contents
      bucket.files.get(key).body
    end

    def bucket
      config.s3_bucket
    end
  end
end
