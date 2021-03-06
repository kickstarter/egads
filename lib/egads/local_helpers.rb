module Egads
  # Some helper methods for all local commands
  module LocalHelpers
    def sha
      @sha ||= run_with_code("git rev-parse --verify #{rev}").strip
    end

    def short_sha
      sha[0,7]
    end

    def tarball
      @tarball ||= S3Tarball.new(sha, seed: options[:seed])
    end

  end
end
