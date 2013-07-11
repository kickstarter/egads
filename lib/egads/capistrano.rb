# Capistrano configuration.
# Use `load 'egads/capistrano'` instead of `load 'deploy'` in your Capfile
# Requires "full_sha" to be set
Capistrano::Configuration.instance.load do

  # Allow overriding egads options (e.g. --force)
  set :egads_options, ''

  namespace :deploy do
    desc "Deploy"
    task :default do
      deploy.check
      deploy.stage
      deploy.release
    end

    desc "Deploy and run migrations"
    task :migrations do
      Capistrano::CLI.ui.ask("Are you sure you want to run migrations? Press enter to continue or ctrl+c to abort")
      set :default_environment, {'MIGRATE' => '1'}
      deploy.default
    end

    desc "Prepares for release by bundling gems, symlinking shared files, etc"
    task :stage do
      run "egads stage #{egads_options } #{full_sha}"
    end

    desc "Runs the release script to symlink a staged deploy and restarts services"
    task :release do
      run "egads release #{egads_options} #{full_sha}"
    end

    desc "Checks that a deployable tarball is on S3; creates it if missing"
    task :check do
      logger.info "Checking tarball for #{full_sha}"
      logger.info "To build the tarball locally, run `bundle exec egads build #{full_sha}"
      logger.info "Waiting for tarball..."
      `bundle exec egads check --wait #{full_sha}`
      abort "Failed to check build" if $?.exitstatus != 0
    end
  end
end
