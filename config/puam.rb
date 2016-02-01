 #!/usr/bin/env puma

 environment ENV['RAILS_ENV'] || 'development'

 daemonize true

 pidfile "//var/www/myapp/tmp/pids/puma.pid"
 stdout_redirect "//var/www/myapp/log/stdout", "//var/www/myapp/log/stderr"

 threads 0, 16

 bind "unix:///tmp/deploy.sock"