module Egads
  class Extract < Group
    include Thor::Actions

    desc "[remote, plumbing] Downloads tarball for SHA from S3 and extracts it to the filesystem"
    class_option :force, type: :boolean, aliases: '-f', default: false, banner: "Overwrite existing files"
    argument :sha, type: :string, required: true, desc: 'git SHA to download and extract'

    attr_accessor :seed_sha, :seed_path

    def setup_environment
      RemoteConfig.setup_environment
    end

    def extract
      if should_extract?
        # Download_patch
        do_download(sha, File.join(patch_dir, "#{sha}.tar.gz"), 'patch')

        do_extract patch_path

        # Download seed
        self.seed_sha = Pathname.new(patch_dir).join("egads-seed").read.strip
        self.seed_path = File.join(RemoteConfig.seed_dir, "#{seed_sha}.tar.gz")
        do_download(seed_sha, seed_path, 'seed')

        do_extract seed_path

        apply_patch
        finish_extraction
      else
        say_status :done, "#{sha} already extracted. Use --force to overwrite"
      end
    end

    protected
    def apply_patch
      inside patch_dir do
        run_with_code "git apply --whitespace=nowarn < #{sha}.patch"
      end
    end

    def finish_extraction
      if options[:force]
        say_status :delete, "Removing release dir #{release_dir} if exists", :yellow
        FileUtils.rm_rf(release_dir)
      end

      say_status :extract, "Moving #{patch_dir} to #{release_dir}"
      File.rename patch_dir, release_dir
      say_status :done, "Extraction complete"
    rescue Errno::ENOTEMPTY
      say_status :error, "#{release_dir} already exists! Did another process create it?", :red
      raise
    end

    def do_download(sha, path, type='patch')
      if should_download?(path)
        say_status :download, "Downloading #{type} tarball for #{sha}", :yellow
        FileUtils.mkdir_p(File.dirname(path))
        tarball = S3Tarball.new(sha, remote: true, seed: 'seed' == type)
        tmp_path = [path, 'tmp', rand(2**32)] * '.' # Use tmp path for atomicity
        duration = Benchmark.realtime do
          File.open(tmp_path, 'w') {|f| tarball.download(f) }
        end
        File.rename(tmp_path, path)
        size = File.size(path)
        say_status :done, "Downloaded in %.1f seconds (%.1f KB/s)" % [duration, (size.to_f / 2**10) / duration]
      else
        say_status :done, "#{type} tarball already downloaded. Use --force to overwrite"
      end
    end

    def do_extract(path)
      inside(patch_dir) do
        # Silence stderr warnings "Ignoring unknown extended header keyword"
        # due to BSD/GNU tar differences.
        run_with_code "tar -zxf #{path} 2>/dev/null"
      end
    end

    # Directory created upon successful extraction
    def release_dir
      RemoteConfig.release_dir(sha)
    end

    # Directory where in-progress extraction occurs
    # Avoids troublesome edge cases where a patch may not not have applied cleanly,
    # or egads crashes during the extraction process
    def patch_dir
      @patch_dir ||= [release_dir, 'extracting', Time.now.strftime("%Y%m%d%H%M%S")] * '.'
    end

    def patch_path
      File.join(patch_dir, "#{sha}.tar.gz")
    end

    def should_download?(path)
      options[:force] || File.zero?(path) || !File.exists?(path)
    end

    def should_extract?
      options[:force] || !File.directory?(release_dir)
    end

  end
end
