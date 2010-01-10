# Conventient tasks for remotely tail'ing log files.
# Available logs that can be streamed out of the box:
#
#  * production.log (your application's production log)
#  * torquebox.log (your torquebox log)
#  * <application>-nginx-access.log (the nginx access log specific to <application> only.)
#  * <application>-nginx-error.log (the nginx error log specific to <application> only.)

namespace :log do
  desc "Stream (tail) the application's production log."
  task :app do
    stream "tail -f '#{shared_path}/log/production.log'"
  end

  desc "Stream (tail) the TorqueBox log."
  task :torquebox do
    stream "tail -f '/home/#{fetch(:user)}/log/torquebox.log'"
  end

  desc "Stream (tail) the nginx access log."
  task :nginx_access do
    stream "tail -f '/home/#{fetch(:user)}/log/#{fetch(:application)}-nginx-access.log'"
  end

  desc "Stream (tail) the nginx error log."
  task :nginx_error do
    stream "tail -f '/home/#{fetch(:user)}/log/#{fetch(:application)}-nginx-error.log'"
  end
end

