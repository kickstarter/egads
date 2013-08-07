module Egads
  class Upload < Group
    include Thor::Actions

    desc "[local, plumbing] Uploads a tarball for SHA to S3"
    argument :sha, type: :string, required: true, desc: 'git SHA to upload'
    class_option :seed, type: :boolean, default: false, banner: "Builds and tags a complete tarball for more efficient patches"


    attr_reader :sha
    def upload
      @sha = sha
      size = File.size(path)
      type = options[:seed] ? 'seed' : 'patch'

      say_status :upload, "Uploading #{type} tarball (%.1f MB)" % (size.to_f / 2**20), :yellow
      duration = Benchmark.realtime do
        tarball.upload(path)
      end
      say_status :done, "Uploaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]

      File.delete(path)
    end

    private
    def tarball
      @tarball ||= S3Tarball.new(sha, seed: options[:seed])
    end

    def path
      tarball.local_tar_path
    end

  end
end
