set :application, "app"
set :deploy_to, "/data/#{application}"
set :repository,  "git://mbp.local/twenty4.git"
set :use_sudo, false

set :scm, :git
set :deploy_via, :remote_cache

set :copy_exclude, %w(config/database.yml)

role :web, "bitfluent"                          # Your HTTP server, Apache/etc
role :app, "bitfluent"                          # This may be the same as your `Web` server
role :db,  "bitfluent", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :start do
  end

  task :stop do
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:update_code", "upload_database_yml"
task :upload_database_yml, :roles => :app, :except => {:no_release => true} do
  db_config = <<-EOF
production:
  adapter: mysql
  encoding: utf8
  username: root
  password: JRuMDzWmou5E20iDe03s
  database: twenty4
  host: localhost
EOF
  put db_config, "#{release_path}/config/database.yml"
end
