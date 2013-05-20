namespace :env do
  task :test_server => [:environment] do
    set :nginx_server_port, '60702'
    set :nginx_server_name, 'f22.test.agideo.com'
    set :domain,              'git.agideo.com'
    set :port,              '60722'
    set :deploy_to,           '/home/agideo/f22'
    set :sudoer,              'agideo'
    set :user,                'agideo'
    set :group,               'agideo'
    set :services_path,       '/etc/init.d'          # where your God and Unicorn service control scripts will go
    set :nginx_path,          '/etc/nginx'
    set :deploy_server,       'production'                   # just a handy name of the server
    invoke :defaults                                         # load rest of the config
    # invoke :"rvm:use[#{rvm_string}]"                       # since my prod server runs 1.9 as default system ruby, there's no need to run rvm:use
  end
end
