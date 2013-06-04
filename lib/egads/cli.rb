
module Egads
  class CLI < Thor
    ##
    # Local commands

    desc "build", "[local] Compiles a deployable tarball of the current commit and uploads it to S3"
    method_options force: :boolean, aliases: '-f', default: false, banner: "Build and overwrite existing tarball on S3"
    method_options 'no-upload' => :boolean, default: false, banner: "Don't upload the tarball to S3"
    def build
      commit = `git rev-parse --verify HEAD`.strip
      s3_tarball = S3Tarball.new(commit)
      if !option[:force] && s3_tarball.exists?
      end
      # Parse commit
      commit = `git rev-parse --verify HEAD`.strip
      # Write revision
      File.open('REVISION', 'w') {|f| f << commit + "\n" }



    end

    method_options force: :boolean, aliases: '-f', default: false, banner: "Overwrite existing tarball on S3"
    desc "upload SHA", "[local, plumbing] Uploads a tarball for SHA to S3"
    def upload(sha)

    end

    ##
    # Remote commands

    desc "extract URL", "[remote, plumbing] Downloads URL from S3 and extracts it to the filesystem"
    def extract(url)

    end

    desc "stage SHA", "[remote] Readies SHA for release. If needed, generates URL for SHA and extracts"
    def stage(sha)

    end

    desc "release SHA", "[remote] Symlinks SHA to current and restarts services. If needed, stages SHA"
    def release(sha)

    end

    desc "clean N", "[remote, plumbing] Deletes old releases, keeping the N most recent (by mtime)"
    def clean(n=4)
    end

  end
end
