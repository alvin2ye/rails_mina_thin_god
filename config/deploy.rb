require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/whenever'
# require 'mina/rvm'  # for rbenv support. (http://rbenv.org)
 
set :domain, '__domain__'
set :port, "22"
set :user, "__username__"
set :deploy_to, '__path__'
set :repository, 'git@git.agideo.com:agideo/__appname__'
set :branch, 'master'
 
set :shared_paths, [
  'config/database.yml', 
  'config/initializers/secret_token.rb', 
  'backup.rb', 
  'log', 'db', 'tmp', 
  "public/uploads"]
 
task :environment do
  # your_bash_env
  # queue! %[source /home/agideo/ruby193env.bash] 
end
 
task :setup => :environment do
  ["config", "log", "db", "tmp", "config/initializers", "public/uploads", "tmp/pids"].each do |dir|
    queue! %[mkdir -p "#{deploy_to}/shared/#{dir}"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/#{dir}"]
  end
end
 
desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'whenever:update'
  end
end
 
task :start => :environment do
  queue! %[cd #{deploy_to}/current && RAILS_ENV=production bundle exec god start -c config/app.god]
end
 
task :status => :environment do
  queue! %[cd #{deploy_to}/current && RAILS_ENV=production bundle exec god status]
  queue! %[echo PID:]
  queue! %[cd #{deploy_to}/current && tail ./tmp/pids/*.pid]
  queue! %[echo ]
end
 
task :restart => [:stop, :start]
  
task :stop => :environment do
  queue! %[cd #{deploy_to}/current && RAILS_ENV=production bundle exec god stop __appname__]
  queue! %[cd #{deploy_to}/current && RAILS_ENV=production bundle exec god quit]
end