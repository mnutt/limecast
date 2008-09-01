require 'fileutils'

PID_FILE = "#{RAILS_ROOT}/tmp/pids/async.pid"

namespace :async do
  desc "Start the async observer workers"
  task :start do
    raise RuntimeError, "async observer is already running" if async_running?

    cmd = "#{RAILS_ROOT}/vendor/plugins/async-observer/bin/worker start"
    puts cmd
    system cmd

    sleep(2)

    if async_running?
      puts "Successfully started async observer workers (pid #{async_pid})."
    else
      puts "Failed to start async observer workers"
    end
  end

  desc "Stop the async observer workers"
  task :stop do
    raise RuntimeError, "async observer is not running." unless async_running?
    pid = async_pid
    system "kill -9 #{pid}"
    puts "Stopped async observer daemon (pid #{pid})"
  end

  desc "Restart the async observer workers"
  task :restart => [:stop, :start]
end

def async_pid
  if File.exist?(PID_FILE)
    `cat #{PID_FILE}`[/\d+/]
  else
    nil
  end
end

def async_running?
  async_pid && `ps -p #{async_pid} | wc -l`.to_i > 1
end
