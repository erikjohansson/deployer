# Bind to 0.0.0.0 for single instances. When passing in the --clustered flag then
# you should not bind to 0.0.0.0. When changing any of these settings you will want to
# re-render and re-upload a new Upstart script using `cap torquebox:install_upstart_script`.
# For more information regarding TorqueBox and Configuration, visit: http://torquebox.org/

set_default :torquebox_run_options, "-b 0.0.0.0"

namespace :torquebox do
  after "deploy:install", "torquebox:install"
  desc "Install the latest stable TorqueBox app server."
  task :install do
    run "gem install torquebox-server"
    run "mkdir -p /home/#{fetch(:user)}/log"
  end

  after "torquebox:install", "torquebox:install_upstart_script"
  desc "Uploads a TorqueBox Upstart script based on the torquebox_run_options."
  task :install_upstart_script do
    template "torquebox.conf.erb", "/tmp/torquebox.conf"
    run "#{sudo} mv /tmp/torquebox.conf /etc/init/torquebox.conf"
    run "sudo restart torquebox || sudo start torquebox"
  end

  %w[start stop restart].each do |command|
    desc "#{command.capitalize} TorqueBox."
    task command, roles: :app do
      run "#{sudo} #{command} torquebox"
    end
  end
end
