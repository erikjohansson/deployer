# Servers and their roles.
server "192.168.33.10", :web, :app, :db, primary: true

# Server-side information.
set :user,        "deployer"
set :application, "myapp"
set :deploy_to,   "/home/#{user}/applications/#{application}"
set :use_sudo,    false

# Repository (if any) configuration.
set :scm,        :git
set :deploy_via, :remote_cache
set :repository, "git@github.com:meskyanichi/#{application}.git"
set :branch,     "master"

# Run on Linux: `$ ssh-add` or on OSX: `$ ssh-add -K` for "forward_agent".
ssh_options[:forward_agent] = true
ssh_options[:port]          = 22
default_run_options[:pty]   = true

# Load ONLY the recipes that are going to be used. (The order is important due to hooks/callbacks)
%w[base user log rbenv nodejs nginx postgresql redis mongodb torquebox].each do |recipe|
  load "config/recipes/#{recipe}"
end

# Review and modify the tasks below on a per-app/language/framework basis.
namespace :deploy do
  after "deploy:update_code", "deploy:post"
  desc "Performs the post-deploy tasks."
  task :post do
    symlinks
    bundle
    migrate
    assets
  end

  desc "Bundles the application's gems with Bundler."
  task :bundle do
    run "cd '#{release_path}' && bundle --without development test"
  end

  desc "Performs an Active Record migration."
  task :migrate do
    run "cd '#{release_path}' && rake db:migrate"
  end

  desc "Precompiles assets from Rails' asset pipeline."
  task :assets do
    run "cd '#{release_path}' && rake assets:precompile"
  end

  desc "Sets up additional symlinks after deploy."
  task :symlinks do
    # Exmaple:
    # run "ln -nfs '#{shared_path}/db/production.sqlite3' '#{release_path}/db/production.sqlite3'"
  end

  after "deploy:setup", "deploy:setup_shared"
  desc "Sets up additional folders/files after deploy:setup."
  task :setup_shared do
    # Example:
    # run "mkdir -p '#{shared_path}/db'"
  end

  desc "Restarts the app server."
  task :restart do
    # Example:
    # restart_torquebox_app
    # restart_upstart_app
  end

  desc "(Re)Starts the application by redeploying the application to TorqueBox."
  task :restart_torquebox_app do
    run "torquebox deploy '#{current_path}' --name #{fetch(:application)}"
  end

  desc "(Re)Starts the application (and related processes, if any) with Upstart."
  task :restart_upstart_app do
    run "cd '#{current_path}'; rbenvsudo foreman export upstart /etc/init -u #{fetch(:user)} -a #{fetch(:application)}"
    run "#{sudo} restart #{fetch(:application)} || #{sudo} start #{fetch(:application)}"
  end
end

