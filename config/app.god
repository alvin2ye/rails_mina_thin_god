RAILS_ROOT = File.join(File.dirname(__FILE__), '..')
ENV["RAILS_ENV"] ||= "development"
 
def generic_monitoring(w, options = {})
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = options[:memory_limit]
      c.times = [3, 5] # 3 out of 5 intervals
    end
  
    restart.condition(:cpu_usage) do |c|
      c.above = options[:cpu_limit]
      c.times = 5
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
 
%w{3400 3401}.each do |port|
    God.watch do |w|
      script = "cd #{RAILS_ROOT} && thin -e #{ENV["RAILS_ENV"]} --pid ./tmp/pids/thin.#{port}.pid -p #{port} -d"
      w.name = "__appname__-thin-#{port}"
      w.group = "__appname__"
      w.interval = 60.seconds
 
      w.start = "#{script} start"
      w.restart = "#{script} restart"
      w.stop = "#{script} stop"
      w.pid_file = "#{RAILS_ROOT}/tmp/pids/thin.#{port}.pid"
      generic_monitoring(w, :cpu_limit => 80.percent, :memory_limit => 300.megabytes)
    end
end

# receive email
God.watch do |w|
  script = "cd #{RAILS_ROOT} && RAILS_ENV=#{ENV["RAILS_ENV"]} bundle exec ruby script/daemon"
  w.name = "robot"
  w.group = "__appname__"
  w.interval = 60.seconds
  w.start = "#{script} start robot.rb"
  w.restart = "#{script} restart robot.rb"
  w.stop = "#{script} stop robot.rb"
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/robot.pid"
  
  w.behavior(:clean_pid_file)
  
  generic_monitoring(w, :cpu_limit => 80.percent, :memory_limit => 200.megabytes)
end

# delayed_job
God.watch do |w|
  script = "cd #{RAILS_ROOT} && bundle exec ruby script/delayed_job -e #{ENV["RAILS_ENV"]} --pid-dir tmp/pids/"
  w.name = "delayed_job"
  w.group = "__appname__"
  w.interval = 60.seconds
  w.start = "#{script} start"
  w.restart = "#{script} restart"
  w.stop = "#{script} stop"
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/delayed_job.pid"
  
  w.behavior(:clean_pid_file)
  
  generic_monitoring(w, :cpu_limit => 80.percent, :memory_limit => 200.megabytes)
end
