# Capistrano configuration.
# Use `load 'egads/capistrano'` instead of `load 'deploy'` in your Capfile
Capistrano::Configuration.instance.load do
  # Set default deploy roles
  set(:deploy_roles, [:web, :app]) unless exists?(:deploy_roles)

  namespace :deploy do
    desc "Deploy"
    task :default, roles: deploy_roles do
      deploy.upload
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
    task :stage, roles: deploy_roles do
      run "egads stage #{sha}"
    end

    desc "Runs the release script to symlink a staged deploy and restarts services"
    task :release, roles: deploy_roles do
      run "egads release #{sha}"
    end

    desc "Checks that a deployable tarball is on S3; creates it if missing"
    task :upload do
      `bundle exec egads build`
      abort "Failed to upload build" if $?.exitstatus != 0
    end
  end
end
