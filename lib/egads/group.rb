module Egads
  class CommandError < Thor::Error; end

  class Group < Thor::Group

    protected
    def run_with_code(command, config={})
      result = nil
      duration = Benchmark.realtime do
        result = run(command, config.merge(capture: true))
      end
      say_status :done, "Finished in %.1f seconds" % duration

      if $? != 0
        raise CommandError.new("`#{command}` failed with exit status #{$?.exitstatus.inspect}")
      end
      result
    end

    # Run command hooks from config file
    # E.g. run_hooks_for(:build, :after)
    def run_hooks_for(cmd, hook)
      say_status :hooks, "Running #{cmd} #{hook} hooks"
      Config.hooks_for(cmd, hook).each do |command|
        run_with_code command
      end
    end

    # Symlinks a directory
    # NB that `ln -f` doesn't work with directories.
    # This is not atomic.
    def symlink_directory(src, dest)
      raise ArgumentError.new("#{src} is not a directory") unless File.directory?(src)
      say_status :symlink, "from #{src} to #{dest}"
      FileUtils.rm_rf(dest)
      FileUtils.ln_s(src, dest)
    end

    def symlink(src, dest)
      raise ArgumentError.new("#{src} is not a file") unless File.file?(src)
      say_status :symlink, "from #{src} to #{dest}"
      FileUtils.ln_sf(src, dest)
    end
  end
end
