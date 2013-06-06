# Capistrano configuration.
# Use `load 'egads/capistrano'` instead of `load 'deploy'` in your Capfile
Capistrano::Configuration.instance.load do
  namespace :deploy do
    desc "Deploy"
    task :default do
      deploy.upload
      deploy.stage
      deploy.release
    end

    desc "Prepares for release by bundling gems, symlinking shared files, etc"
    task :stage do
      run "egads stage #{sha}"
    end

    desc "Runs the release script to symlink a staged deploy and restarts services"
    task :release do
      run "egads release #{sha}"
    end

    desc "Checks that a deployable tarball is on S3; creates it if missing"
    task :upload do
      `bundle exec egads build`
      abort "Failed to upload build" if $?.exitstatus != 0
    end
  end
end
