require 'thor'
module Egads
  class Commands < Thor
    include Thor::Actions
    # Options: -f --force # build even if target exists
    # --keep-file don't delete the tarball after it's uploaded
    desc "build", "Creates a tarball of the HEAD commit and uploads to S3"
    method_option :force, :aliases => "-f", :desc => "Build the tarball even if it exists"
    def build
      if ! options[:force] && tarball_exists? # Check if tarball exists
      end

      # Create tarball

      # Add extra_paths
      puts "build!"
    end


    desc "upload", "Upload TARBALL to S3"
    def upload(tarball)
    end
  end
end
