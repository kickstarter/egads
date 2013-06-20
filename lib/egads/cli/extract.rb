module Egads
  class CLI

    desc "extract SHA", "[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem"
    method_option :force, type: :boolean, default: false, banner: "Overwrite existing files"
    attr_reader :sha
    def extract(sha)
      @sha = sha
      RemoteConfig.setup_environment

      inside release_dir do
        if should_download?
          say_status :download, "Downloading tarball for #{sha}"
          duration = Benchmark.realtime do
            File.open(remote_tarball_path, 'w') {|f| f << tarball.contents }
          end
          size = File.size(remote_tarball_path)
          say_status :done, "Downloaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]
        else
          say_status :done, "Tarball already downloaded. Use --force to overwrite"
        end

        # Check revision file to see if tarball is already extracted
        if should_extract?
          say_status :extract "Extracting tarball for #{sha}"
          run_with_code "tar -zxf #{remote_tarball_path}"
        else
          say_status :done, "Tarball already extracted. Use --force to overwrite"
        end

        mark_as_extracted
      end
    end

    private
    def remote_tarball_path
      File.join(release_dir, "#{sha}.tar.gz")
    end

    def tarball
      @tarball ||= S3Tarball.new(sha, true)
    end

    def should_download?
      options[:force] || File.zero?(remote_tarball_path) || !File.exists?(remote_tarball_path)
    end

    def extract_flag_path
      File.join(release_dir, '.egads-extract-success')
    end

    def should_extract?
      options[:force] || !File.exists?(extract_flag_path)
    end

    def mark_as_extracted
      FileUtils.touch(extract_flag_path)
    end
  end
end
