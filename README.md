个人博客
=======

# Centos Mina Deploy Rails Use Puma
## 服务器准备
### 用户权限设置

    添加用户
      user add  -m -G wheel -s /bin/bash newuser
    添加密码
      passwd newpassword
      
### 切换用户
    
    su newuser(root)
    
### 创建部署目标文件夹

    mkdir -p /home/newuser
    chown -R newuser /home/newuser    
    
## Rails环境安装
### centos 
1. 安装所需要的软件

    sudo yum install -y git-core openssl bzip2 bzip2-devel gcc ruby-devel zlib-devel libxml2
        
2. 安装mysql(root 用户)

    sudo yum install mysql-server
    sudo mysql_secure_installation
    sudo service mysqld start
    
3. 安装node

    wget http://nodejs.org/dist/v0.12.2/node-v0.12.2.tar.gz下载
    tar -zvxf node-v0.12.2.tar.gz解压
    cd node-v0.12.2
      sudo make & make install编译
      
4. 安装nginx

  * mkdir /etc/yum.repos.d/nginx.repo 设置Nginx的镜像配置文件


      [nginx]
      name=nginx repo
      baseurl=http://nginx.org/packages/centos/     $releasever/$basearch/
      gpgcheck=0
      enabled=1
   
      
      
  * sudo yum install nginx

5. 安装rvm

  * curl -L https://get.rvm.io | bash -s stable 下载rvm
  * sed -i 's!ftp.ruby-lang.org/pub/ruby!ruby.taobao.org/mirrors/ruby!' $rvm_path/config/db 
  将rvm的资源地址换到taobao
  
6. 安装ruby
  * rvm install ruby2.1.4
  * 使用淘宝gemsouece 
  
      gem sources --remove https://rubygems.org/
      gem sources -a http://ruby.taobao.org/
      
7. 安装bundle
    
    gem install bundle --no-rdoc --no-ri
    
8. 添加ssh.pub to github
  * $ssh-keygen -t rsa -C xxxxx@gmail.com（注册github时的email）
  *  登陆github，将服务器公钥添加在自己的项目路径下面的settings-> deploy keys   

## 项目设置
###配置Puma
1. 首先要在Gemfile中添加gem 'puma'
2. myapp/config/puam.rb
 

         #!/usr/bin/env puma
    
          environment ENV['RAILS_ENV'] || 'production'
          
          daemonize true
          
          pidfile "/home/user/shared/tmp/pids/puma.pid"
          stdout_redirect "/home/user/shared/tmp/log/stdout", "/home/user/shared/tmp/log/stderr"
          
          threads 0, 16
          
          bind "unix:///home/user/shared/tmp/sockets/puma.sock"

      
3. myapp/bin/puma.sh




          #! /bin/sh
          PUMA_CONFIG_FILE=/home/user/current/config/puma.rb
          PUMA_PID_FILE=/home/user/shared/tmp/pids/puma.pid
          PUMA_SOCKET=/home/user/shared/tmp/sockets/puma.sock

          # check if puma process is running
          puma_is_running() {
            if [ -S $PUMA_SOCKET ] ; then
              if [ -e $PUMA_PID_FILE ] ; then
                if cat $PUMA_PID_FILE | xargs pgrep -P > /dev/null ; then
                  return 0
                else
                  echo "No puma process found"
                fi
              else
                echo "No puma pid file found"
              fi
            else
              echo "No puma socket found"
            fi
        
            return 1
          }
        
          case "$1" in
            start)
              echo "Starting puma..."
                rm -f $PUMA_SOCKET
                touch -f $PUMA_SOCKET
                touch -f $PUMA_PID_FILE
                if [ -e $PUMA_CONFIG_FILE ] ; then
                  bundle exec puma -C $PUMA_CONFIG_FILE
                else
                  bundle exec puma
                fi
        
              echo "done"
              ;;
        
            stop)
              echo "Stopping puma..."
                kill -s SIGTERM `cat $PUMA_PID_FILE`
                rm -f $PUMA_PID_FILE
                rm -f $PUMA_SOCKET
              echo "done"
              ;;
        
            restart)
              if puma_is_running ; then
                echo "Hot-restarting puma..."
                kill -s SIGUSR2 `cat $PUMA_PID_FILE`
        
                echo "Doublechecking the process restart..."
                sleep 5
                if puma_is_running ; then
                  echo "done"
                  exit 0
                else
                  echo "Puma restart failed :/"
                fi
              fi
        
              echo "Trying cold reboot"
              echo [ -S $PUMA_SOCKET ]
              /home/user/shared/puma.sh start
              ;;
        
            *)
              echo "Usage: /home/user/shared/puma.sh {start|stop|restart}" >&2
              ;;
          esac
          
      
      
*****     
**需要注意的是：puma.sh最后在部署时候房子share路劲下，每次deploy时候不需要重新修改文件权限**
*****
**后面使用mina配置部署时候需要先修改文件权限以防报错 -> chmod +x app_path/shared/puma.sh**

*****


###配置Mina
1. 在Gemfile中添加gem 'mina'
2. mina init生成deploy.rb文件
3. 设置myapp/config/deploy.rb


        require 'mina/bundler'
        require 'mina/rails'
        require 'mina/git'
        # require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
        require 'mina/rvm'    # for rvm support. (http://rvm.io)
        # require 'mina/puma'
        
        # Basic settings:
        #   domain       - The hostname to SSH to.
        #   deploy_to    - Path to deploy into.
        #   repository   - Git repo to clone from. (needed by mina/git)
        #   branch       - Branch name to deploy. (needed by mina/git)
        set :user, 'user'
        set :term_mode, :nil
        set :domain, ''
        set :deploy_to, ''
        set :repository, 'git@github.com:yumu01/mysite.git'
        set :branch, 'staging'
        set :stage, 'production'
        set :forward_agent, true
        set :app_path, lambda { "#{deploy_to}/current" }
        
        # For system-wide RVM install.
        set :rvm_path, '/usr/local/rvm/scripts/rvm'
        
        # Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
        # They will be linked in the 'deploy:link_shared_paths' step.
        set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log']
        
        # Optional settings:
        #   set :user, 'foobar'    # Username in the server to SSH to.
        #   set :port, '30000'     # SSH port number.
        #   set :forward_agent, true     # SSH forward_agent.
        
        # This task is the environment that is loaded for most commands, such as
        # `mina deploy` or `mina rake`.
        task :environment do
          # If you're using rbenv, use this to load the rbenv environment.
          # Be sure to commit your .ruby-version or .rbenv-version to your repository.
          # invoke :'rbenv:load'
        
          # For those using RVM, use this to load an RVM version@gemset.
          invoke :'rvm:use[2.1.4@myapp]'
        end
        
        # Put any custom mkdir's in here for when `mina setup` is ran.
        # For Rails apps, we'll make some of the shared paths that are shared between
        # all releases.
        task :setup => :environment do
          queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
          queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]
        
          queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
          queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]
        
          queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
          queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
          queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'."]
        
          queue %[
            repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
            repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'` &&
            if [ -z "${repo_port}" ]; then repo_port=22; fi &&
            ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
          ]
        end
        
        desc "Deploys the current version to the server."
        task :deploy => :environment do
          to :before_hook do
            # Put things to run locally before ssh
          end
          deploy do
            # Put things that will set up an empty directory into a fully set-up
            # instance of your project.
            invoke :'git:clone'
            invoke :'deploy:link_shared_paths'
            invoke :'bundle:install'
            invoke :'rails:db_migrate'
            invoke :'rails:assets_precompile'
            invoke :'deploy:cleanup'
        
            to :launch do
              invoke :'puma:restart'
              # queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
              # queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
            end
          end
        end
        
        namespace :puma do
          desc "Start the application"
          task :start do
            queue 'echo "-----> Start Puma"'
            queue "cd #{app_path} && RAILS_ENV=#{stage} && #{app_path}/shared/puma.sh start", :pty => false
          end
        
          desc "Stop the application"
          task :stop do
            queue 'echo "-----> Stop Puma"'
            queue "cd #{app_path} && RAILS_ENV=#{stage} && #{app_path}/shared/puma.sh stop"
          end
        
          desc "Restart the application"
          task :restart do
            queue 'echo "-----> Restart Puma"'
            queue "cd #{app_path} && RAILS_ENV=#{stage} && #{app_path}/shared/puma.sh restart"
          end
        end
  
  
###开始部署
1. 编辑/config/application.rb
  * config.assets.precompile += %w(....)在括号中加入app/assets/和lib/assets/还有vender/assets/里面js/css的文件
2. 编辑/config/environments/production.rb
  * config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' 要用Nginx

3. mina setup 报错处理
4. 配置 /var/www/myapp/shared/config/database.yml
5. mina deploy

### Nginx设置
1. 修改/etc/nginx/nginx.conf

    
        user  user;
        worker_processes  1;
        error_log  /var/log/nginx/error.log warn;
    
        pid        /var/run/nginx.pid;
    
        events {
        
            worker_connections  1024;
        
        }
        
        http {
    
            include       /etc/nginx/mime.types;
          
            default_type  application/octet-stream;
      
      
      
            log_format  main    '$remote_addr - $remote_user [$time_local] "$request" '
                              '$status $body_bytes_sent "$http_referer" '
    
                              '"$http_user_agent" "$http_x_forwarded_for"';
    
            access_log  /var/log/nginx/access.log  main;
            sendfile        on;
            #tcp_nopush     on;
        
            keepalive_timeout  65;
        
            #gzip  on;
      
            include /etc/nginx/conf.d/*.conf;
        
    
            upstream app {
                 # Path to Puma SOCK file, as defined previously
                 server unix:/app_root/shared/sockets/puma.sock fail_timeout=0;
            }
            server {
                listen 80;
                server_name www.example;
        
                root /app_root/public;
        
                try_files $uri/index.html $uri @app;
        
                location @app {
                  proxy_pass http://localhost:9292;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header Host $http_host;
                  proxy_redirect off;
                }
        
                error_page 500 502 503 504 /500.html;
                client_max_body_size 4G;
                keepalive_timeout 10;
            }
        }
            
    
    
2. 重启nginx 
     
        sudo service nginx restart
  
  
  

  


    
            
  
      
    
  
    

