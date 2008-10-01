require 'fileutils'
 
PID_FILE = "#{RAILS_ROOT}/tmp/pids/dj.pid"
 
namespace :jobs do
  desc "Start the dj workers"
  task :start do
    raise RuntimeError, "dj worker is already running" if dj_running?
 
    cmd = "#{RAILS_ROOT}/script/job_runner &> #{RAILS_ROOT}/log/dj.log &"
    puts cmd
    system cmd
 
    sleep(5)
 
    if dj_running?
      puts "Successfully started dj workers (pid #{dj_pid})."
    else
      puts "Failed to start dj workers"
    end
  end
 
  desc "Stop the dj workers"
  task :stop do
    raise RuntimeError, "dj is not running." unless dj_running?
    pid = dj_pid
    system "kill -9 #{pid}"
    puts "Stopped dj daemon (pid #{pid})"
  end
 
  desc "Restart the dj workers"
  task :restart => [:stop, :start]
end
 
def dj_pid
  if File.exist?(PID_FILE)
    `cat #{PID_FILE}`[/\d+/]
  else
    nil
  end
end
 
def dj_running?
  dj_pid && `ps -p #{dj_pid} | wc -l`.to_i > 1
end
