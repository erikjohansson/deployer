# Will upload the `public_ssh_key` and append it to the `~/.ssh/authorized_keys`. You may change
# the local key that's being uploaded by changing the `public_ssh_key` variable.
# It will not re-upload already uploaded keys, and it will only try to upload if the file could be found,
# else it will skip the process.

set_default :public_ssh_key, "#{ENV['HOME']}/.ssh/id_rsa.pub"

namespace :user do
  after "deploy:install", "user:upload_bashrc"
  desc "Uploads the bashrc file in the templates directory to the users home directory on the server."
  task :upload_bashrc do
    template "bashrc", "/home/#{fetch(:user)}/.bashrc"
  end

  after "deploy:setup", "user:install_ssh_key"
  desc "Installs public ssh key on to the server."
  task :install_ssh_key do
    if File.exist?(public_ssh_key)
      public_ssh_key_data = File.read(public_ssh_key).chomp
      authorized_keys = "/home/#{fetch(:user)}/.ssh/authorized_keys"
      run "mkdir -p /home/#{fetch(:user)}/.ssh"
      if not capture("cat '#{authorized_keys}' || true").include?(public_ssh_key_data)
        run "echo '#{public_ssh_key_data}' >> '#{authorized_keys}'"
        puts "Added #{public_ssh_key} to #{authorized_keys}."
      else
        puts "#{authorized_keys} already contains this public key."
      end
    else
      puts "Could not find local public ssh key in: #{public_ssh_key}. Skipping."
    end
  end
end
