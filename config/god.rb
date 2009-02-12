RAILS_ROOT = File.join(File.dirname(__FILE__), '..')
RAILS_ENV  = ENV['RAILS_ENV'] || 'production'

# Dear God, Please watch over our long running scripts. Amen.

def default_conditions(w)
  w.log         = File.join(RAILS_ROOT, "log/god.log")
  w.interval    = 30.seconds
  w.start_grace = 1.minute
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 1.minute
      c.running  = false
    end
  end
end

def cd_and(cmd)
  "cd #{RAILS_ROOT} && #{cmd}"
end

God.watch do |w|
  default_conditions(w)

  script = File.join(RAILS_ROOT, "script/update_sources_control")

  w.name     = "update_sources"
  w.start    = cd_and("RAILS_ENV=#{RAILS_ENV} sudo -u limecast #{script} start")
  w.stop     = cd_and("RAILS_ENV=#{RAILS_ENV} sudo -u limecast #{script} stop")
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/update_sources.pid")
  
  w.behavior(:clean_pid_file)
end

rakefile = File.join(RAILS_ROOT, "Rakefile")

God.watch do |w|
  default_conditions(w)

  w.name     = "delayed_job"
  w.start    = cd_and("RAILS_ENV=#{RAILS_ENV} sudo -u limecast rake -f #{rakefile} jobs:start")
  w.stop     = cd_and("RAILS_ENV=#{RAILS_ENV} sudo -u limecast rake -f #{rakefile} jobs:stop")
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/dj.pid")
  
  w.behavior(:clean_pid_file)
end

God.watch do |w|
  default_conditions(w)

  w.name     = "sphinx"
  w.start    = cd_and("RAILS_ENV=#{RAILS_ENV} sudo -u limecast rake -f #{rakefile} ts:start > /tmp/thinking_sphinx_error.log 2>&1")
  w.stop     = cd_and("RAILS_ENV=#{RAILS_ENV} sudo -u limecast rake -f #{rakefile} ts:stop  > /tmp/thinking_sphinx_error.log 2>&1")
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/searchd.pid")

  w.behavior(:clean_pid_file)
end

