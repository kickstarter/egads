module Egads
  class Upload < Group
    include Thor::Actions

    desc "[local, plumbing] Uploads a tarball for SHA to S3"
    argument :sha, type: :string, required: true, desc: 'git SHA to upload'

    attr_reader :sha
    def upload
      @sha = sha
      size = File.size(path)

      say_status :upload, "Uploading tarball (%.1f MB)" % (size.to_f / 2**20), :yellow
      duration = Benchmark.realtime do
        tarball.upload(path)
      end
      say_status :done, "Uploaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]

      File.delete(path)
    end

    private
    def tarball
      @tarball ||= S3Tarball.new(sha)
    end

    def path
      tarball.local_gzipped_path
    end

  end
end
