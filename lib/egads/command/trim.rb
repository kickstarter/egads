module Egads
  class Trim < Group
    include Thor::Actions


    desc "[remote, plumbing] Deletes old releases and seeds, keeping the N most recent (by mtime)"
    def trim(n=4)
      # Trim old releases
      inside RemoteConfig.extract_to do
        trim_glob('*', n)
      end

      # Trim seeds
      inside RemoteConfig.seed_dir do
        trim_glob('*.tar.gz', n)
      end
    end

    protected
    def trim_glob(glob, n)
      paths = Dir.glob(glob).sort_by{|path| File.mtime(path) }.reverse[n..-1].to_a
      paths.each do |path|
        say_status :trim, "Deleting #{path}"
        FileUtils.rm_rf(path)
      end
    end

  end
end
