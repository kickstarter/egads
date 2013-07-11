module Egads
  class Check < Group
    include Thor::Actions
    include Egads::LocalHelpers

    desc "[local] Checks if a deployable tarball of the current commit already exists on S3"
    class_option :wait, type: :boolean, aliases: '-w', default: false, banner: "Wait for the build to exist. Poll S3 every 2 seconds."
    argument :rev, type: :string, default: 'HEAD', desc: 'git revision to check'

    def check
      say_status :rev, "#{rev} parsed to #{sha}"

      wait_for_build if options[:wait]

      if tarball.exists?
        say_status :exists, "Tarball for #{sha} exists"
        exit 0
      else
        say_status :missing, "Tarball for #{sha} does not exist", :red
        exit 1
      end
    end

    protected
    def wait_for_build
      say_status :wait, "Waiting for tarball to exist...", :yellow
      loop do
        start = Time.now
        break if tarball.exists?
        printf '.'
        sleep [1 - (Time.now - start), 0].max
      end
      printf "\n"
    end

  end
end
