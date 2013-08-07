module Egads
  class Extract < Group
    include Thor::Actions

    desc "[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem"
    class_option :force, type: :boolean, default: false, banner: "Overwrite existing files"
    argument :sha, type: :string, required: true, desc: 'git SHA to download and extract'

    def setup_environment
      RemoteConfig.setup_environment
    end

    def download
      if should_download?
        say_status :download, "Downloading tarball for #{sha}", :yellow
        FileUtils.mkdir_p(release_dir)
        duration = Benchmark.realtime do
          File.open(path, 'w') {|f| f << tarball.contents }
        end
        size = File.size(path)
        say_status :done, "Downloaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]
      else
        say_status :done, "Tarball already downloaded. Use --force to overwrite"
      end
    end

    def extract
      # Check revision file to see if tarball is already extracted
      if should_extract?
        # Silence stderr warnings "Ignoring unknown extended header keyword"
        # due to BSD/GNU tar.
        inside(release_dir) { run_with_code "tar -zxf #{path} 2>/dev/null" }
      else
        say_status :done, "Tarball already extracted. Use --force to overwrite"
      end
    end

    def mark_as_extracted
      FileUtils.touch(extract_flag_path)
    end

    protected
    def release_dir
      RemoteConfig.release_dir(sha)
    end

    def path
      File.join(release_dir, "#{sha}.tar.gz")
    end

    def tarball
      @tarball ||= S3Tarball.new(sha, remote: true)
    end

    def should_download?
      options[:force] || File.zero?(path) || !File.exists?(path)
    end

    def extract_flag_path
      File.join(release_dir, '.egads-extract-success')
    end

    def should_extract?
      options[:force] || !File.exists?(extract_flag_path)
    end

  end
end
