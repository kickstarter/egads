require 'thor'
require 'benchmark'
class Thor
  class CommandError < Error; end

  module Actions
    # runs command, raises CommandFailedError unless exit status is 0.
    # Also logs duration
    def run_or_die(command, config={})
      result = nil
      duration = Benchmark.realtime do
        result = run(command, config)
      end
      if behavior == :invoke && $?.exitstatus != 0
        message = "#{command} failed with %s" % ($?.exitstatus ? "exit status #{$?.exitstatus}" : "no exit status (likely force killed)")
        raise Thor::CommandFailedError.new(message)
      end

      say_status :done, "in %.1f seconds" % duration, config.fetch(:verbose, true)

      result
    end

    def run_with_code(command, config={})
      result = nil
      duration = Benchmark.realtime do
        result = run(command, config.merge(capture: true))
      end

      if $? != 0
        raise CommandError.new("`#{command}` failed with exit status #{$?.exitstatus.inspect}")
      end
      result
    end

  end
end
