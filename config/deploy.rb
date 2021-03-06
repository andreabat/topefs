# This is a sample Capistrano config file for EC2 on Rails.

set :application, "yourapp"

#set :deploy_via, :copy       # optional, see Capistrano docs for details
#set :copy_strategy, :export  # optional, see Capistrano docs for details

set :repository, "http://svn.foo.com/svn/#{application}/trunk"

# NOTE: for some reason Capistrano requires you to have both the public and
# the private key in the same folder, the public key should have the 
# extension ".pub".
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/your-ec2-key"]

# Your EC2 instances
role :web,      "ec2-72-44-50-90.z-1.compute-1.amazonaws.com"
role :app,      "ec2-72-44-50-90.z-1.compute-1.amazonaws.com"
role :db,       "ec2-72-44-50-90.z-1.compute-1.amazonaws.com", :primary => true
role :memcache, "ec2-72-44-50-90.z-1.compute-1.amazonaws.com"

set :rails_env, "production"

# EC2 on Rails config
set :ec2onrails_config, {
  # S3 bucket used by the ec2onrails:db:restore task
  :restore_from_bucket => "your-bucket",
  
  # S3 bucket used by the ec2onrails:db:archive task
  :archive_to_bucket => "your-other-bucket",
  
  # Set a root password for MySQL. Run "cap ec2onrails:db:set_root_password"
  # to enable this. This is optional, and after doing this the
  # ec2onrails:db:drop task won't work, but be aware that MySQL accepts 
  # connections on the public network interface (you should block the MySQL
  # port with the firewall anyway). 
  :mysql_root_password => "gandalf",
  
  # Any extra Ubuntu packages to install if desired
  :packages => ["logwatch", "imagemagick"],
  
  # Any extra RubyGems to install if desired: can be "gemname" or if a 
  # particular version is desired "gemname -v 1.0.1"
  :rubygems => ["rmagick", "rfacebook -v 0.9.7"],
  
  # Set the server timezone. run "cap -e ec2onrails:server:set_timezone" for 
  # details
  :timezone => "Canada/Eastern",
  
  # Files to deploy to the server (they'll be owned by root). It's intended
  # mainly for customized config files for new packages installed via the 
  # ec2onrails:server:install_packages task. 
  :server_config_files_root => "../server_config",
  
  # If config files are deployed, some services might need to be restarted
  :services_to_restart => %w(apache2 postfix sysklogd)
}
