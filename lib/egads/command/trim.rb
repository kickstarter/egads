module Egads
  class Trim < Thor::Group
    include Thor::Actions


    desc "[remote, plumbing] Deletes old releases, keeping the N most recent (by mtime)"
    def trim(n=4)
      inside RemoteConfig.extract_to do
        dirs = Dir.glob('*').sort_by{|path| File.mtime(path) }.reverse[n..-1].to_a
        dirs.each do |dir|
          say_status :trim, "Deleting #{dir}"
          FileUtils.rm_rf(dir)
        end
      end
    end

  end
end
