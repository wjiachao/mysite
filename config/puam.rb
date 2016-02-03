 #!/usr/bin/env puma

environment ENV['RAILS_ENV'] || 'production'

daemonize true

pidfile "/home/jiachao/shared/tmp/pids/puma.pid"
stdout_redirect "/home/jiachao/shared/tmp/log/stdout", "/home/jiachao/shared/tmp/log/stderr"

threads 0, 16

bind "unix:///home/jiachao/shared/tmp/sockets/puma.sock"