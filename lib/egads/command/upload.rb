module Egads
  class CLI
    desc "upload SHA", "[local, plumbing] Uploads a tarball for SHA to S3"
    attr_reader :sha
    def upload(sha)
      @sha = sha
      path = tarball.local_gzipped_path
      size = File.size(path)

      say_status :upload, "Uploading tarball (%.1f MB)" % (size.to_f / 2**20)
      duration = Benchmark.realtime do
        tarball.upload(path)
      end
      say_status :done, "Uploaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]

      File.delete(path)
    end

    private
    def tarball
      S3Tarball.new(sha)
    end


  end
end
