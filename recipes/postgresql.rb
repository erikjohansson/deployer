# The installation adds a postgresql.conf to /etc/postgresql/9.1/main/postgresql.conf.
# Use this file to further configure the PostgreSQL server. After you finish configuring PostgreSQL,
# you can either use Capistrano to restart the PostgreSQL server with `cap postgresql:restart`
# or on the server through SSH with `service postgresql restart`.

set_default(:pg_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }

namespace :postgresql do
  after "deploy:install", "postgresql:install"
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} add-apt-repository ppa:pitti/postgresql"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql libpq-dev"
  end

  # after "deploy:setup", "postgresql:create_database"
  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{fetch(:application)} with password '#{pg_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{fetch(:application)} owner #{fetch(:application)};"}
  end

  after "deploy:setup", "postgresql:setup"
  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end

  after "deploy:finalize_update", "postgresql:symlink"
  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  %w[start stop restart].each do |command|
    desc "#{command.capitalize} PostgreSQL server."
    task command do
      run "#{sudo} service postgresql #{command}"
    end
  end
end
