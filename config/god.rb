RAILS_ROOT = File.join(File.dirname(__FILE__), '..')

# Dear God, Please watch over our long running scripts. Amen.

def default_conditions(w)
  w.interval    = 30.seconds
  w.start_grace = 1.minute
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 1.minute
      c.running  = false
    end
  end
end

God.watch do |w|
  default_conditions(w)

  w.name     = "update_sources"
  w.start    = "cd #{RAILS_ROOT} && script/update_sources start"
  w.stop     = "cd #{RAILS_ROOT} && script/update_sources stop"
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/update_sources.pid")
  
  w.behavior(:clean_pid_file)
end

rakefile = File.join(RAILS_ROOT, "Rakefile")

God.watch do |w|
  default_conditions(w)

  w.name     = "delayed_job"
  w.start    = "cd #{RAILS_ROOT} && rake jobs:start"
  w.stop     = "cd #{RAILS_ROOT} && rake jobs:stop"
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/dj.pid")
  
  w.behavior(:clean_pid_file)
end

God.watch do |w|
  default_conditions(w)

  w.name     = "sphinx"
  w.start    = "cd #{RAILS_ROOT} && rake ts:index; cd #{RAILS_ROOT} && rake ts:start"
  w.stop     = "cd #{RAILS_ROOT} && rake ts:stop"
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/searchd.pid")

  w.behavior(:clean_pid_file)
end

