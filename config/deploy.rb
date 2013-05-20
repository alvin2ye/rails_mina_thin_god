$:.unshift './lib'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

require 'mina/defaults'
require 'mina/extras'
require 'mina/nginx'
require 'mina/whenever'

Dir['lib/mina/servers/*.rb'].each { |f| load f }

###########################################################################
# Common settings for all servers
###########################################################################

set :app,                'rails_mina_thin_god'
set :repository,         'git://github.com/alvin2ye/rails_mina_thin_god.git'
set :keep_releases,       9999        #=> I like to keep all my releases
set :default_server,     :test_server

###########################################################################
# Tasks
###########################################################################

set :server, ENV['to'] || default_server
invoke :"env:#{server}"

task :environment do
  invoke :'rbenv:load'
end

set :shared_paths, [
  'config/database.yml',
  'config/config.yml',
  'config/thin.yml',
  'config/initializers/session_store.rb'
]

queue echo_cmd ". $HOME/.profile"

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'  
    queue 'sudo /etc/init.d/nginx reload'
  end
end



