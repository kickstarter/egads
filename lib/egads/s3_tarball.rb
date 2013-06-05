module Egads
  class S3Tarball
    attr_reader :sha
    def initialize(sha)
      @sha = sha
    end

    def key
      [Config.s3_prefix, "#{sha}.tar.gz"].compact * '/'
    end

    def exists?
      bucket.files.head(key)
    end

    def local_tar_path
      "tmp/#{sha}.tar"
    end

    def local_gzipped_path
      "#{local_tar_path}.gz"
    end

    def upload(path=local_gzipped_path)
      File.open(path) {|f|
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

