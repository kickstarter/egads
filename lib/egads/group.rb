require 'open3'
module Egads
  class CommandError < Thor::Error; end

  class Group < Thor::Group

    # Always exit on failure
    def self.exit_on_failure?
      true
    end

    protected
    def run_with_code(command, options={})

      say_status :run, "#{command}", options.fetch(:verbose, true)

      capture = []
      duration = Benchmark.realtime do
        Open3.popen2e(command) do |_, out, thread|
          out.each do |line|
            puts line if options[:stream]
            capture << line
          end

          unless thread.value == 0
            raise CommandError.new("`#{command}` failed with exit status #{thread.value.exitstatus.inspect}")
          end
        end
      end
      say_status :done, "Finished in %.1f seconds" % duration, options.fetch(:verbose, true)

      capture.join
    end

    # Run command hooks from config file
    # E.g. run_hooks_for(:build, :after)
    def run_hooks_for(cmd, hook)
      say_status :hooks, "Running #{cmd} #{hook} hooks"
      Config.hooks_for(cmd, hook).each do |command|
        run_with_code(command, stream: true)
      end
    end

    # Symlinks a directory (not atomically)
    # NB that `ln -f` doesn't work with directories.
    def symlink_directory(src, dest)
      raise ArgumentError.new("#{src} is not a directory") unless File.directory?(src)
      say_status :symlink, "from #{src} to #{dest}"
      FileUtils.rm_rf(dest)
      File.symlink(src, dest)
    end

    def symlink(src, dest)
      raise ArgumentError.new("#{src} is not a file") unless File.file?(src)
      say_status :symlink, "from #{src} to #{dest}"
      FileUtils.ln_s(src, dest)
    #rescue Errno::EEXIST # This could happen, don't bother rescuing it.
    end
  end
end
