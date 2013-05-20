namespace :env do
  task :production => [:environment] do
    set :nginx_server_port, '80'
    set :nginx_server_name, 'f22.test.agideo.com'
    set :domain,              '106.186.20.216'
    set :port,              '22'
    set :deploy_to,           "/home/agideo/rails_app/#{app}"
    set :sudoer,              'agideo'
    set :user,                'agideo'
    set :group,               'agideo'
    set :services_path,       '/etc/init.d'          # where your God and Unicorn service control scripts will go
    set :nginx_path,          '/etc/nginx'
    set :deploy_server,       'production'                   # just a handy name of the server
    invoke :defaults                                         # load rest of the config
  end
end
