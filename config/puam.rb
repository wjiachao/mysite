 #!/usr/bin/env puma

 environment ENV['RAILS_ENV'] || 'production'

 daemonize true

 pidfile "//home/jiachao/tmp/pids/puma.pid"
 stdout_redirect "//home/jiachao/log/stdout", "//home/jiachao/log/stderr"

 threads 0, 16

 bind "unix:///tmp/deploy.sock"