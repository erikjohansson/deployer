# Define a list of Ruby versions to install via rbEnv. Bundler gem will be installed
# for all versions listed. The first version listed in the Array will become the system default.
# List of available Ruby versions:
#  https://github.com/sstephenson/ruby-build/tree/master/share/ruby-build

# set_default :ruby_versions, %w[jruby-1.6.7 1.9.3-p125]
set_default :ruby_versions, %w[jruby-1.6.7]

namespace :rbenv do
  after "deploy:install", "rbenv:install"
  desc "Install rbenv, one or more Ruby versions, sets a system default, and installs the Bundler gem."
  task :install, roles: :app do
    run "#{sudo} apt-get -y install curl git-core"
    run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
    run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
    run %q{eval "$(rbenv init -)"}
    ruby_versions.each do |ruby_version|
      run "rbenv install #{ruby_version}"
      run "rbenv global #{ruby_version}"
      run "gem install bundler --no-ri --no-rdoc"
      run "gem install jruby-openssl --no-ri --no-rdoc" if ruby_version =~ /jruby/
    end
    run "rbenv global #{ruby_versions[0]}"
    run "rbenv rehash"
  end
end
