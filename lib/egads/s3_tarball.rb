module Egads
  class S3Tarball
    attr_reader :sha
    def initialize(sha)
      @sha = sha
    end

    def key
      [Config.s3_prefix, "#{sha}.#{Config::TARBALL_EXTENSION}"].compact * '/'
    end

    def exists?
      bucket.files.head(key)
    end

    def upload(local_path)
      File.open(local_path) {|f|
        bucket.files.create(key: key, body: f)
      }
    end

    # Generate a secure URL, expires in 1 hour by default
    def url(expires = Time.now + 3600)
      bucket.files.new(key: key).url(expires)
    end

    def bucket
      Config.s3_bucket
    end
  end
end

