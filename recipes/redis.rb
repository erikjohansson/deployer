# The installation adds a redis.conf to /etc/redis/redis.conf.
# Use this file to further configure the Redis server. After you finish configuring Redis,
# you can either use Capistrano to restart the Redis server with `cap redis:restart`
# or on the server through SSH with `service redis-server restart`.

namespace :redis do
  after "deploy:install", "redis:install"
  desc "Install the latest stable release of Redis."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} add-apt-repository ppa:rwky/redis"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install redis-server"
  end

  %w[start stop restart].each do |command|
    desc "#{command.capitalize} Redis server."
    task command do
      run "#{sudo} service redis-server #{command}"
    end
  end
end
